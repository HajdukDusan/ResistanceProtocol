// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "./NOI.sol";
import "./Parameters.sol";
import "./Treasury.sol";

error CDPManager__OnlyOwnerAuthorization();
error CDPManager__UnauthorizedLiquidator();
error CDPManager__NotAuthorized();
error CDPManager__InvalidCDPIndex();
error CDPManager__ContractNotAuthorized();
error CDPManager__NotOwner();
error CDPManager__HasDebt();
error CDPManager__LiquidationRatioReached();
error CDPManager__ZeroTokenMint();
error CDPManager__UnknownParameter();
error CDPManager__UnknownContract();

contract CDPManager {
    struct CDP {
        // Total amount of collateral locked in a CDP
        uint256 lockedCollateral; // [wad]
        // Total amount of debt generated by a CDP
        uint256 generatedDebt; // [wad]
        // Address of owner
        address owner;
        // accumulated stability fee before changing generatedDebt amount
        uint256 accumulatedFee;
        // time of last calculation of accumulated stability fee
        uint256 updatedTime;
    }

    uint256 constant SECONDS_PER_YEAR = 31536000;

    uint256 public ethRp;

    uint256 private totalSupply;
    uint256 private totalDebt;
    uint256 public cdpi; // auto increment index for CDPs
    mapping(uint256 => CDP) private cdpList; // CDPId => CDP

    NOI private NOI_COIN;

    uint256 private lastUnmintedNOICalculationTimestamp;

    address liquidatorContractAddress;
    address parametersContractAddress;
    address treasuryContractAddress;

    address public immutable owner;

    modifier onlyOwner() {
        if (msg.sender != owner) revert CDPManager__OnlyOwnerAuthorization();
        _;
    }

    modifier onlyLiquidatorContract() {
        if (msg.sender != liquidatorContractAddress)
            revert CDPManager__UnauthorizedLiquidator();
        _;
    }
    uint256 internal constant TWENTY_SEVEN_DECIMAL_NUMBER = 10**27;
    uint256 internal constant EIGHTEEN_DECIMAL_NUMBER = 10**18;

    modifier HasAccess(address _user) {
        if (msg.sender != _user) revert CDPManager__NotAuthorized();
        _;
    }

    // --- Auth ---
    mapping(address => bool) public authorizedAccounts;

    function addAuthorization(address account) external isOwner {
        authorizedAccounts[account] = true;
        emit AddAuthorization(account);
    }

    function removeAuthorization(address account) external isOwner {
        authorizedAccounts[account] = false;
        emit RemoveAuthorization(account);
    }

    modifier CDPExists(uint256 _cdpIndx) {
        if (cdpList[_cdpIndx].owner == address(0))
            revert CDPManager__InvalidCDPIndex();
        _;
    }

    modifier isOwner() {
        if (owner != msg.sender) revert CDPManager__NotOwner();
        _;
    }

    modifier isAuthorized() {
        if (authorizedAccounts[msg.sender] == false)
            revert CDPManager__ContractNotAuthorized();
        _;
    }

    // EVENTS

    event CDPOpen(address indexed _user, uint256 indexed _cdpId, uint _value);
    event TransferCollateral(
        address indexed _user,
        uint256 indexed _cdpId,
        uint _value
    );
    event CDPClose(address indexed _user, uint256 indexed _cdpId);
    event OwnershipTransfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _cdpId
    );
    event MintCDP(address indexed _from, uint256 indexed _cdpId, uint _amount);
    event RepayCDP(address indexed _from, uint256 indexed _cdpId, uint _amount);
    event AddAuthorization(address _account);
    event RemoveAuthorization(address _account);
    event ModifyParameters(bytes32 indexed _parameter, uint256 _data);
    event ModifyContract(bytes32 indexed _contract, address _newAddress);

    /*
     * @notice Modify general uint256 params
     * @param _parameter The name of the parameter modified
     * @param _data New value for the parameter
     */
    function modifyParameters(bytes32 _parameter, uint256 _data)
        external
        isOwner
    {
        if (_parameter == "cdpi") cdpi = _data;
        else revert CDPManager__UnknownParameter();
        emit ModifyParameters(_parameter, _data);
    }

    /*
     * @notice Modify contract address
     * @param _contract The name of the contract modified
     * @param _newAddress New address for the contract
     */
    function modifyContracts(bytes32 _contract, address _newAddress)
        external
        isOwner
    {
        if (_contract == "NOI") NOI_COIN = NOI(_newAddress);
        else revert CDPManager__UnknownContract();
        emit ModifyContract(_contract, _newAddress);
    }

    constructor(address _owner, address _noiCoin) {
        owner = _owner;
        authorizedAccounts[msg.sender] = true;
        totalSupply = 0;
        cdpi = 0;
        ethRp = 1000 * EIGHTEEN_DECIMAL_NUMBER;
        lastUnmintedNOICalculationTimestamp = block.timestamp;
        NOI_COIN = NOI(_noiCoin);
    }

    function setLiquidatorContractAddress(address _liquidatorContractAddress)
        public
        onlyOwner
    {
        liquidatorContractAddress = _liquidatorContractAddress;
    }

    function setParametersContractAddress(address _parametersContractAddress)
        public
        onlyOwner
    {
        parametersContractAddress = _parametersContractAddress;
    }

    function setTreasuryContractAddress(address _treasuryContractAddress)
        public
        onlyOwner
    {
        treasuryContractAddress = _treasuryContractAddress;
    }

    /*
     * @notice open a new cdp for a given _user address
     * @param _user address of cdp owner
     */
    function openCDP(address _user)
        public
        payable
        HasAccess(_user)
        returns (uint256)
    {
        cdpi = cdpi + 1;
        cdpList[cdpi] = CDP(msg.value, 0, _user, 0, block.timestamp);
        totalSupply = totalSupply + msg.value;

        emit CDPOpen(_user, cdpi, msg.value);
        return cdpi;
    }

    /*
     * @notice adds collateral to an existing CDP
     * @param _cdpIndex index of cdp
     */
    function transferCollateralToCDP(uint _cdpIndex)
        public
        payable
        CDPExists(_cdpIndex)
    {
        cdpList[_cdpIndex].lockedCollateral =
            cdpList[_cdpIndex].lockedCollateral +
            msg.value;
        totalSupply = totalSupply + msg.value;
        emit TransferCollateral(cdpList[_cdpIndex].owner, _cdpIndex, msg.value);
    }

    /*
     * @notice close CDP if you have 0 debt
     * @param _cdpIndex index of cdp
     */
    function closeCDP(uint256 _cdpIndex)
        public
        CDPExists(_cdpIndex)
        HasAccess(cdpList[_cdpIndex].owner)
    {
        if (getDebtWithSF(_cdpIndex) != 0) {
            revert CDPManager__HasDebt();
        }
        (bool sent, ) = payable(cdpList[_cdpIndex].owner).call{
            value: cdpList[_cdpIndex].lockedCollateral
        }("");
        if (sent == false) revert();
        totalSupply = totalSupply - cdpList[_cdpIndex].lockedCollateral;
        emit CDPClose(cdpList[_cdpIndex].owner, _cdpIndex);
        delete cdpList[_cdpIndex];
    }

    /*
     * @notice view total supply of ether in contract
     */
    function getTotalSupply() public view returns (uint256) {
        return totalSupply;
    }

    /*
     * @notice view the state of one CDP
     * @param _cdpIndex index of cdp
     */
    function getOneCDP(uint256 _cdpIndex)
        public
        view
        CDPExists(_cdpIndex)
        returns (CDP memory searchedCDP)
    {
        searchedCDP = cdpList[_cdpIndex];
    }

    /*
     * @notice calculate only debt from stability fee
     * @param _cdpIndex index of cdp
     */
    function getOnlySF(uint256 _cdpIndex) public view returns (uint256) {
        uint8 SF = Parameters(parametersContractAddress).getSF();
        CDP memory cdp = cdpList[_cdpIndex];
        uint fee = cdpList[_cdpIndex].accumulatedFee +
            (cdp.generatedDebt *
            SF *
            (block.timestamp - cdp.updatedTime)) / (SECONDS_PER_YEAR * 100);
        return fee;
    }

    /*
     * @notice calculate debt with stability fee included
     * @param _cdpIndex index of cdp
     */
    function getDebtWithSF(uint256 _cdpIndex) public view returns (uint256) {
        uint total = cdpList[_cdpIndex].generatedDebt +
            getOnlySF(_cdpIndex);
        return total;
    }

    function getOnlyDebt(uint256 _cdpIndex) public view returns (uint256) {
        return cdpList[_cdpIndex].generatedDebt;        
    }

    function recalculateSF(uint256 _cdpIndex) public {
        cdpList[_cdpIndex].accumulatedFee = getOnlySF(_cdpIndex);
        cdpList[_cdpIndex].updatedTime = block.timestamp;
    }

    /*
     * @notice transfer ownership of CDP
     * @param _from address of owner
     * @param _to address of new owner
     * @param _cdpIndex index of cdp
     */
    function transferOwnership(
        address _from,
        address _to,
        uint256 _cdpIndex
    ) public CDPExists(_cdpIndex) HasAccess(_from) {
        cdpList[_cdpIndex].owner = _to;
        emit OwnershipTransfer(_from, _to, _cdpIndex);
    }

    /*
     * @notice mint coins for cdp
     * @param _cdpIndex index of cdp
     * @param _amount amount of tokens to mint
     */
    function mintFromCDP(uint256 _cdpIndex, uint256 _amount)
        public
        CDPExists(_cdpIndex)
        HasAccess(cdpList[_cdpIndex].owner)
    {
        if (_amount == 0) revert CDPManager__ZeroTokenMint();
        CDP memory user_cdp = cdpList[_cdpIndex];

        uint256 LR = Parameters(parametersContractAddress).getLR() *
            EIGHTEEN_DECIMAL_NUMBER;

        // check if the new minted coins will be under liquidation ratio
        uint256 newTotalUserDebt = (getDebtWithSF(_cdpIndex) + _amount);
        uint256 CR = (user_cdp.lockedCollateral * ethRp * 100) /
            (newTotalUserDebt);

        if (CR < LR) revert CDPManager__LiquidationRatioReached();

        recalculateSF(_cdpIndex);
        transferSFtoTreasury();

        cdpList[_cdpIndex].generatedDebt += _amount;
        totalDebt = totalDebt + _amount;

        NOI_COIN.mint(user_cdp.owner, _amount);
        emit MintCDP(cdpList[_cdpIndex].owner, _cdpIndex, _amount);
    }

    function transferSFtoTreasury() private returns (uint256) {
        uint8 SF = Parameters(parametersContractAddress).getSF();
        uint amount = (totalDebt *
            SF *
            (block.timestamp - lastUnmintedNOICalculationTimestamp)) /
            (SECONDS_PER_YEAR * 100);
        lastUnmintedNOICalculationTimestamp = block.timestamp;
        Treasury(payable(treasuryContractAddress)).receiveUnmintedNoi(amount);
        return amount;
    }

    /*
     * @notice repay debt in coins
     * @param _cdpIndex index of cdp
     * @param _amount amount of tokens to repay
     */
    function repayToCDP(uint256 _cdpIndex, uint256 _amount)
        public
        CDPExists(_cdpIndex)
    {
        uint256 amount = _amount;
        recalculateSF(_cdpIndex);
        uint totalUserDebt = cdpList[_cdpIndex].generatedDebt +
            cdpList[_cdpIndex].accumulatedFee;

        transferSFtoTreasury();

        if (amount > totalUserDebt) amount = totalUserDebt;
        if (amount <= cdpList[_cdpIndex].accumulatedFee) {
            cdpList[_cdpIndex].accumulatedFee -= amount;
        } else {
            uint256 onlyDebt = amount - cdpList[_cdpIndex].accumulatedFee;
            cdpList[_cdpIndex].accumulatedFee = 0;
            cdpList[_cdpIndex].generatedDebt -= onlyDebt;
            totalDebt -= onlyDebt;
        }
        NOI_COIN.burn(msg.sender, amount);
        emit RepayCDP(cdpList[_cdpIndex].owner, _cdpIndex, amount);
    }

    /*
     * @notice repay total debt and close position
     * @param _cdpIndex index of cdp
     */
    function repayAndCloseCDP(uint256 _cdpIndex)
        public
        CDPExists(_cdpIndex)
    {
        recalculateSF(_cdpIndex);
        uint256 amount = cdpList[_cdpIndex].accumulatedFee + cdpList[_cdpIndex].generatedDebt;
        transferSFtoTreasury();
        

        NOI_COIN.burn(msg.sender, amount);

        cdpList[_cdpIndex].accumulatedFee = 0;
        cdpList[_cdpIndex].generatedDebt = 0;

        emit RepayCDP(cdpList[_cdpIndex].owner, _cdpIndex, amount);

        closeCDP(_cdpIndex);
    }

    /*
     * @notice liquidate position
     * @param _cdpIndex index of cdp
     * @param _liquidatorUsr address that initiated liquidation
     */
    function liquidatePosition(uint _cdpIndex, address _liquidatorUsr)
        public
        payable
        onlyLiquidatorContract
        CDPExists(_cdpIndex)
    {
        (bool sent, ) = payable(msg.sender).call{
            value: cdpList[_cdpIndex].lockedCollateral
        }("");
        if (sent == false) revert();
        totalSupply = totalSupply - cdpList[_cdpIndex].lockedCollateral;

        // burn dept from liquidator balance
        NOI_COIN.burn(_liquidatorUsr, getDebtWithSF(_cdpIndex));

        emit CDPClose(cdpList[_cdpIndex].owner, _cdpIndex);
        delete cdpList[_cdpIndex];
    }

    function setEthRp(uint256 _ethRp) public isAuthorized {
        ethRp = _ethRp;
    }
}
