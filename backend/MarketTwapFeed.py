ABI_MARKETTWAPFEED= [{"inputs":[{"internalType":"uint256","name":"_updateTimeInterval","type":"uint256"},{"internalType":"uint256","name":"_twapWindowSize","type":"uint256"},{"internalType":"address","name":"_lendingPool","type":"address"},{"internalType":"address","name":"_ethTwapFeed","type":"address"},{"internalType":"address","name":"_rateSetter","type":"address"},{"internalType":"address","name":"_owner","type":"address"}],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[],"name":"MarketTwapFeed__NotActive","type":"error"},{"inputs":[],"name":"MarketTwapFeed__NotAuthorized","type":"error"},{"inputs":[],"name":"MarketTwapFeed__NotOwner","type":"error"},{"inputs":[],"name":"MarketTwapFeed__TimeIntervalDidNotPass","type":"error"},{"anonymous":False,"inputs":[{"indexed":True,"internalType":"address","name":"from","type":"address"},{"indexed":True,"internalType":"uint256","name":"currentPrice","type":"uint256"},{"indexed":True,"internalType":"uint256","name":"twapPrice","type":"uint256"},{"indexed":False,"internalType":"uint256","name":"timestamp","type":"uint256"}],"name":"UpdateValues","type":"event"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"addAuthorization","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"authorizedAccounts","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"daiPriceFeed","outputs":[{"internalType":"contract AggregatorV3Interface","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getDaiPrice","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getMarketPrice","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getTwap","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"marketTwapPrice","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"removeAuthorization","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"shutdown","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"twapWindowSize","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"update","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"updateTimeInterval","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}]
ADDRESS_MARKETTWAPFEED= "0x94fFA1C7330845646CE9128450F8e6c3B5e44F86"