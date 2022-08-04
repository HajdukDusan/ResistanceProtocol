// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error MarketTwapFeed__TimeIntervalDidNotPass();

abstract contract LengingPoolLike {
    function getReserves()
        public
        view
        virtual
        returns (
            uint256 noiCount,
            uint256 daiCount,
            uint256 timestamp
        );
}

contract MarketTwapFeed {
    uint256 public marketTwapPrice = 0;
    uint256 public immutable updateTimeInterval;
    uint256 public immutable twapWindowSize;

    // hardcode Chainlink NOI/USD Price Feed
    AggregatorV3Interface public daiPriceFeed;
    LengingPoolLike private lengingPool;
    uint256 private lastUpdateTimestamp;
    uint256 private prevCumulativeValue = 0;
    uint256 private prevPrice;

    struct Snapshot {
        uint256 cumulativeValue;
        uint256 timestamp;
    }

    Snapshot[] private snapshotHistory;
    uint256 private historyIndx = 0;

    modifier IntervalPassed() {
        if (block.timestamp - lastUpdateTimestamp < updateTimeInterval)
            revert MarketTwapFeed__TimeIntervalDidNotPass();
        _;
    }

    /*
     * @param _updateTimeInterval sets the minimum time interval for update
     * @param _twapWindowSize sets the number of updates needed for twap to change
     * @param _lendongPool get the oracle
     */
    constructor(
        uint256 _updateTimeInterval,
        uint256 _twapWindowSize,
        address _lendingPool
    ) {
        lastUpdateTimestamp = block.timestamp;

        daiPriceFeed = AggregatorV3Interface(
            0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9
        );

        updateTimeInterval = _updateTimeInterval;
        twapWindowSize = _twapWindowSize + 1;
        lengingPool = LengingPoolLike(_lendingPool);

        // set initial stuff
        snapshotHistory.push(Snapshot(0, block.timestamp));
        //prevPrice = getMarketPrice();
    }

    /*
     * @notice update the cumulative price if minimum interval passed
     */
    function update() public IntervalPassed {
        uint256 timePassed = block.timestamp - lastUpdateTimestamp;

        uint256 nextCumulativeValue = prevCumulativeValue +
            prevPrice *
            timePassed;

        Snapshot memory snap;

        // if array is not full get the first snap and push the current
        if (twapWindowSize != snapshotHistory.length) {
            snapshotHistory.push(
                Snapshot(nextCumulativeValue, block.timestamp)
            );
            historyIndx = 0;
            snap = snapshotHistory[0];
        } else {
            snap = snapshotHistory[historyIndx];
            snapshotHistory[historyIndx] = Snapshot(
                nextCumulativeValue,
                block.timestamp
            );
        }

        marketTwapPrice =
            (nextCumulativeValue - snap.cumulativeValue) /
            (block.timestamp - snap.timestamp);

        // prepare for next iteration
        historyIndx = (historyIndx + 1) % (twapWindowSize - 1);
        prevCumulativeValue = nextCumulativeValue;
        prevPrice = getMarketPrice();
        lastUpdateTimestamp = block.timestamp;
    }

    /*
     * @notice fetch the most recent market twap
     */
    function getMarketTwap() public view returns (uint256) {
        return marketTwapPrice;
    }

    /*
     * @notice calculate the market price
     */
    function getMarketPrice() public view returns (uint256) {
        (uint256 noiCount, uint256 daiCount, ) = lengingPool.getReserves();

        uint256 daiPrice = getDaiPrice();

        return (daiCount * daiPrice) / noiCount;
    }

    /*
     * @notice get dai price in usd
     */
    function getDaiPrice() public view returns (uint256) {
        (, int256 price, , , ) = daiPriceFeed.latestRoundData();
        return uint256(price);
    }
}
