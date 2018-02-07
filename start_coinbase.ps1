# define env vars
# TODO - move to a setenv script & source here
$env:TORQHOME = ("" + (Get-Location) + "/TorQ")
$env:KDBCODE=(${env:TORQHOME} + "/code")
$env:KDBHDB=("" + (Get-Location) + "/hdb/database")
$env:KDBWDB=("" + (Get-Location) + "/wdbhdb")
$env:KDBAPPCODE=("" + (Get-Location) + "/code")
$env:KDBAPPCONFIG=("" + (Get-Location) + "/appconfig")
$env:KDBBASEPORT=6000
$env:KDBSTACKID="-stackid ${env:KDBBASEPORT}"
$env:KDBCONFIG="${env:TORQHOME}/config"
$env:KDBLOG=("" + (Get-Location) + "/logs")
$env:KDBHTML="${env:TORQHOME}/html"
$env:KDBLIB="${env:TORQHOME}/lib"

# getfield | get one field from config for one process passed by procname
function getfield {
    param($procname, $field)
    $csv = Import-Csv -path ${env:KDBAPPCONFIG}/process.csv                                         # load config CSV
    foreach($proc in $csv){                                                                         # iterate over processes
        if ($proc.procname -eq $procname) {                                                         # find input process
            if ("" -ne $proc.$field) {                                                              # check field is populated
                $str=(" -" + $field + " " + $proc.$field)                                           # append command line flag
                $str=$str -replace '\${', '${env:'                                                  # workaround for env vars
                Write-Output $ExecutionContext.InvokeCommand.ExpandString($str)                     # substitute in env vars
            }
            return                                                                                  # return once correct process has been found
        }
    }
}

# startstr | generate startup string for one proc passed by procname
function startstr {
    param($procname)
    $params = "proctype U localtime g T w load schemafile tplogdir"                                 # params to load
    $start = "${env:TORQHOME}\torq.q -procname $procname ${env:KDBSTACKID}"                         # basic command line
    foreach($p in $params.split(" ")) {                                                             # iterate over params
        $a = getfield $procname $p                                                                  # get each param
        $start = ($start + $a)                                                                      # append to start string
    }
    Write-Output $start                                                                             # output startup string
}

# runproc | run one process passed by procname
function runproc {
    param($procname)
    $path = startstr $procname                                                                      # generate startup string for named process
    Start-Process "q.exe" $path -RedirectStandardOutput logs/torq$procname.txt                      # start process with redirected stdout
}

# getall | return all procnames with "startwithall" flag in cfg
function getall {
    $csv = Import-Csv -path ${env:KDBAPPCONFIG}/process.csv                                         # load config csv
    $csv | Where-Object {$_.startwithall -eq 1} | ForEach-Object { Write-Output $_.procname }       # filter to procs with "startwithall" flag, return procnames
}

foreach($proc in (getall)) { runproc $proc }                                                        # generate list of "all" procs, run all
#TODO allow options besides "all"