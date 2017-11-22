# Load the environment
. ./setenv.sh

# sets the base port for a default TorQ installation
export KDBHDB=${TORQHOME}/hdb/database
export KDBWDB=${TORQHOME}/wdbhdb
export KDBSTACKID="-stackid ${KDBBASEPORT}"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$KDBLIB/l32

##### EMAILS #####
# this is where the emails will be sent to 
# export DEMOEMAILRECEIVER=user@torq.co.uk

# also set the email server configuration in config/settings/default.q
##### END EMAILS #####

# launch the discovery service
echo 'Starting discovery proc...'
q ${TORQHOME}/torq.q -load ${KDBCODE}/processes/discovery.q ${KDBSTACKID} -proctype discovery -procname discovery1 -U appconfig/passwords/accesslist.txt -localtime  </dev/null >$KDBLOG/torqdiscovery.txt 2>&1 &

# launch the tickerplant, rdb, hdb
echo 'Starting tp...'
q ${TORQHOME}/torq.q -load ${KDBCODE}/processes/tickerplant.q -schemafile database -tplogdir ${TORQHOME}/hdb ${KDBSTACKID} -proctype tickerplant -procname tickerplant1 -U appconfig/passwords/accesslist.txt -localtime </dev/null >$KDBLOG/torqtp.txt 2>&1 &

echo 'Starting rdb...'
q ${TORQHOME}/torq.q -load ${KDBCODE}/processes/rdb.q ${KDBSTACKID} -proctype rdb -procname rdb1 -U appconfig/passwords/accesslist.txt -localtime -g 1 -T 30 </dev/null >$KDBLOG/torqrdb.txt 2>&1 &

echo 'Starting ctp...'
q ${TORQHOME}/torq.q -load ${KDBCODE}/processes/chainedtp.q ${KDBSTACKID} -proctype chainedtp -procname chainedtp1 -U appconfig/passwords/accesslist.txt -localtime </dev/null >$KDBLOG/torqchainedtp.txt 2>&1 &

echo 'Starting hdb1...'
q ${TORQHOME}/torq.q -load ${KDBHDB} ${KDBSTACKID} -proctype hdb -procname hdb1 -U appconfig/passwords/accesslist.txt -localtime -g 1 -T 60 -w 4000 </dev/null >$KDBLOG/torqhdb1.txt 2>&1 &

echo 'Starting hdb2...'
q ${TORQHOME}/torq.q -load ${KDBHDB} ${KDBSTACKID} -proctype hdb -procname hdb2 -U appconfig/passwords/accesslist.txt -localtime -g 1 -T 60 -w 4000 </dev/null >$KDBLOG/torqhdb2.txt 2>&1 &

# launch the gateway
echo 'Starting gw...'
q ${TORQHOME}/torq.q -load ${KDBCODE}/processes/gateway.q ${KDBSTACKID} -proctype gateway -procname gateway1 -U appconfig/passwords/accesslist.txt -localtime -g 1 -w 4000 </dev/null >$KDBLOG/torqgw.txt 2>&1 &

# launch the monitor
echo 'Starting monitor...'
q ${TORQHOME}/torq.q -load ${KDBCODE}/processes/monitor.q ${KDBSTACKID} -proctype monitor -procname monitor1 -localtime </dev/null >$KDBLOG/torqmonitor.txt 2>&1 &

# launch the reporter
echo 'Starting reporter...'
q ${TORQHOME}/torq.q -load ${KDBCODE}/processes/reporter.q ${KDBSTACKID} -proctype reporter -procname reporter1 -U appconfig/passwords/accesslist.txt -localtime </dev/null >$KDBLOG/torqreporter.txt 2>&1 &

# launch housekeeping
echo 'Starting housekeeping proc...'
q ${TORQHOME}/torq.q -load ${KDBCODE}/processes/housekeeping.q ${KDBSTACKID} -proctype housekeeping -procname housekeeping1 -U appconfig/passwords/accesslist.txt -localtime </dev/null >$KDBLOG/torqhousekeeping.txt 2>&1 &

# launch sort processes
echo 'Starting sorting proc...'
q ${TORQHOME}/torq.q -load ${KDBCODE}/processes/wdb.q -s -2 ${KDBSTACKID} -proctype sort -procname sort1 -U appconfig/passwords/accesslist.txt -localtime -g 1 </dev/null >$KDBLOG/torqsort.txt 2>&1 & # sort process

# launch wdb
echo 'Starting wdb...'
q ${TORQHOME}/torq.q -load ${KDBCODE}/processes/wdb.q ${KDBSTACKID} -proctype wdb -procname wdb1 -U appconfig/passwords/accesslist.txt -localtime -g 1 </dev/null >$KDBLOG/torqwdb.txt 2>&1 &  # pdb process

# launch compress
echo 'Starting compression proc...'
q ${TORQHOME}/torq.q -load ${KDBCODE}/processes/compression.q ${KDBSTACKID} -proctype compression -procname compression1 -localtime </dev/null >$KDBLOG/torqcompress1.txt 2>&1 &  # compression process

# launch feed
echo 'Starting feed...'
q ${TORQHOME}/torq.q -load ${KDBAPPCODE}/processes/feed.q ${KDBSTACKID} -proctype feed -procname feed1 -localtime </dev/null >$KDBLOG/btcfeed.txt 2>&1 &

# launch sort slave 1
echo 'Starting sort slave-1...'
q ${TORQHOME}/torq.q -load ${KDBCODE}/processes/wdb.q ${KDBSTACKID} -proctype sortslave -procname sortslave1 -localtime -g 1 </dev/null >$KDBLOG/torqsortslave1.txt 2>&1 &

# launch sort slave 2 
echo 'Starting sort slave-2...'
q ${TORQHOME}/torq.q -load ${KDBCODE}/processes/wdb.q ${KDBSTACKID} -proctype sortslave -procname sortslave2 -localtime -g 1 </dev/null >$KDBLOG/torqsortslave2.txt 2>&1 &
