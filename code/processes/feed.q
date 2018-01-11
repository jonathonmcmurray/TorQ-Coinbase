/- use the discovery service to find the tickerplant to publish data to
.servers.startup[]
h:.servers.gethandlebytype[`tickerplant;`any]

feed:{
  a:{@[(.j.k .Q.hg`$.feed.baseurl,x,"/",y)`data;`sym`typ;:;(x except "-";y)]}\:/:[.feed.coinlist;.feed.pricelist];
  t:select time:.z.P,
           bid: "F"$first amount where typ like "sell",
           ask: "F"$first amount where typ like "buy" ,
           spot:"F"$first amount where typ like "spot"
  by `$sym
  from raze a;
  h(`.u.upd;`btc;get flip `time xcols 0!t);
 }

.timer.repeat[.proc.cp[];0Wp;0D00:00:30.000;(`feed;`);"Publish Feed"];
