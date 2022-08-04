const BigNumber = require('big-number');

async function openAndMintFromCDP(CDPManagerContractObj, account, collateral, debt){

    const txOpenCDP = await CDPManagerContractObj.connect(account).openCDP(account.address, {value: ethers.utils.parseEther(collateral)});
    await txOpenCDP.wait();
    const getCDPIndex = await CDPManagerContractObj.connect(account).cdpi();
    const cdpIndex = getCDPIndex.toString();

    const txmintFromCDPManager = await CDPManagerContractObj.connect(account).mintFromCDP(cdpIndex, BigNumber(10).pow(18).mult(debt).toString());
    await txmintFromCDPManager.wait();

    return cdpIndex;
}

async function approveAndLiquidatePosition(LiquidatorContractObj,noiContractObj,cdpIndex, account,amount){

    const approveCDPManager = await noiContractObj.connect(account).approve(CDPManagerContractObj.address, BigNumber(10).pow(18).mult(amount).toString());
    await approveCDPManager.wait();

    const liquidateCDP = await LiquidatorContractObj.connect(account).liquidateCDP(cdpIndex);
    await liquidateCDP.wait();
}

async function repayToCDP(CDPManagerContractObj,noiContractObj,cdpIndex,account,amount){
    
    const txApprove = await noiContractObj.connect(account).approve(CDPManagerContractObj.address, BigNumber(10).pow(18).mult(amount).toString());
    await txApprove.wait();

    const txRepay = await CDPManagerContractObj.connect(account).repayToCDP(cdpIndex, BigNumber(10).pow(18).mult(amount).toString());
    return await txRepay.wait();

}

module.exports = {
    openAndMintFromCDP,
    approveAndLiquidatePosition,
    repayToCDP
}