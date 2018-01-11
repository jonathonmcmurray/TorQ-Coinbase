// Bespoke Feed config : Finance Starter Pack

\d .servers	
enabled:1b						
CONNECTIONS:enlist `tickerplant		// Feedhandler connects to the tickerplant
HOPENTIMEOUT:30000

\d .feed
baseurl:":https://api.coinbase.com/v2/prices/"  //URL used for Coinbase API requests
coinlist:("BTC-USD";"ETH-USD";"BCH-USD")        //list of currency pairs to request prices for
pricelist:("buy";"sell";"spot")                 //list of types of price to get for each coin
