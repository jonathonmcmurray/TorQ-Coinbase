/- use the discovery service to find the tickerplant to publish data to
.servers.startup[]
h:.servers.gethandlebytype[`tickerplant;`any]

feed:{
  a:{@[(.j.k .Q.hg`$":https://api.coinbase.com/v2/prices/BTC-USD/",x)`data;`typ;:;x]}'[("buy";"sell";"spot")];
  t:select time:1#.z.P,sym:first `$(base,'currency),
           bid: "F"$first amount where typ like "sell",
           ask: "F"$first amount where typ like "buy" ,
           spot:"F"$first amount where typ like "spot"
  from a;
  h(`.u.upd;`btc;t);
 }

.timer.repeat[.proc.cp[];0Wp;0D00:00:30.000;(`feed;`);"Publish Feed"];
