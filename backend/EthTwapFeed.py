ABI_ETHTWAPFEED= [{"inputs":[{"internalType":"address","name":"_owner","type":"address"},{"internalType":"uint256","name":"_updateTimeInterval","type":"uint256"},{"internalType":"uint256","name":"_twapWindowSize","type":"uint256"},{"internalType":"address","name":"_ethPriceFeed","type":"address"}],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[],"name":"EthTwapFeed__NotActive","type":"error"},{"inputs":[],"name":"EthTwapFeed__NotAuthorized","type":"error"},{"inputs":[],"name":"EthTwapFeed__NotOwner","type":"error"},{"inputs":[],"name":"EthTwapFeed__TimeIntervalDidNotPass","type":"error"},{"anonymous":False,"inputs":[{"indexed":True,"internalType":"address","name":"from","type":"address"},{"indexed":True,"internalType":"uint256","name":"ethCurrentPrice","type":"uint256"},{"indexed":True,"internalType":"uint256","name":"ethTwapPrice","type":"uint256"},{"indexed":False,"internalType":"uint256","name":"timestamp","type":"uint256"}],"name":"UpdateValues","type":"event"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"addAuthorization","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"authorizedAccounts","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"ethTwapPrice","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getEthPrice","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getTwap","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"removeAuthorization","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"shutdown","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"twapWindowSize","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"updateAndGetTwap","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"updateTimeInterval","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}]
ADDRESS_ETHTWAPFEED= "0x4593ed9CbE6003e687e5e77368534bb04b162503"