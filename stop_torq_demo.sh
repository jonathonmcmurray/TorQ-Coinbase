# load env script
. ./setenv.sh

#kill all torq procs
echo 'Shutting down TorQ...'
q ${TORQHOME}/torq.q -load ${KDBCODE}/processes/kill.q -proctype kill -procname killtick -.servers.CONNECTIONS sortslave feed rdb tickerplant chainedtp hdb gateway housekeeping monitor discovery wdb sort reporter compression metrics </dev/null >$KDBLOG/torqkill.txt 2>&1 &
