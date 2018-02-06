# Load the environment
. ./setenv.sh

# sets the base port for a default TorQ installation
export KDBHDB=${PWD}/hdb/database
export KDBWDB=${PWD}/wdbhdb
export KDBSTACKID="-stackid ${KDBBASEPORT}"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$KDBLIB/l32

getfield() {
  fieldno=`awk -F, '{if(NR==1) for(i=1;i<=NF;i++){if($i=="'$2'") print i}}' appconfig/process.csv`  # get number for field based on headers
  fieldval=`awk -F, '{if(NR == '$1') print $'$fieldno'}' appconfig/process.csv`                     # pull one field from one line of file
  if [ "" == "$fieldval" ]; then                                                                    # check for empty string
    echo ""                                                                                         # return nothing if nothing in config
  else
    echo " -"$2 $fieldval | envsubst                                                                # append comand line param at start of value, substitute env vars
  fi
 }

findproc() {
  pgrep -f "\-procname $1 $KDBSTACKID \-proctype $(getfield $1 proctype)"
 }

start() {
  if [ -z `findproc $1` ]; then
    procno=`awk '/'$1'/{print NR}' appconfig/process.csv`                                           # get line number for file
    params="proctype U localtime g T w load schemafile tplogdir"                                    # list of params to read from config
    sline="q ${TORQHOME}/torq.q -procname $1 ${KDBSTACKID}"                                         # base part of startup line
    for p in $params;                                                                               # iterate over params
    do
      a=`getfield $procno $p`;                                                                      # get param
      sline="$sline$a";                                                                             # append to startup line
    done
    echo "Starting $1..."
    eval "${sline} </dev/null >${KDBLOG}/torq${1}.txt 2>&1 &"                                       # redirect output and run in background
  else
    echo "$1 already running"
  fi
 }

if [ "$1" == "all" ]; then
 procs="discovery1 tickerplant1 rdb1 hdb1 hdb2 wdb1 sort1 gateway1 monitor1 housekeeping1 reporter1 compression1 feed1 chainedtp1 sortslave1 sortslave2"
else
 procs=$*
fi

for p in $procs;
do
  start $p;
done
