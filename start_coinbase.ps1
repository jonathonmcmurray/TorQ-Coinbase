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

# SSL verification

#if(![System.IO.File]::Exists("certs\cabundle.pem")){
#  Invoke-WebRequest https://curl.haxx.se/ca/cacert.pem -OutFile certs/cabundle.pem
#}
$env:SSL_CA_CERT_FILE=("" + (Get-Location) + "/certs/cabundle.pem")

# getfield | get one field from config for one process passed by procname
function getfield {
    param($procname, $field)
    $csv = Import-Csv -path ${env:KDBAPPCONFIG}/process.csv                                         # load config CSV
    foreach($proc in $csv){                                                                         # iterate over processes
        if ($proc.procname -eq $procname) {                                                         # find input process
            if ("" -ne $proc.$field) {                                                              # check field is populated
                $str=$proc.$field -replace '\${', '${env:'                                          # workaround for env vars
                Write-Output $ExecutionContext.InvokeCommand.ExpandString($str)                     # substitute in env vars
            }
            return                                                                                  # return once correct process has been found
        }
    }
}

function parameter {
    param($procname, $field)
    $str=getfield $procname $field
    if ($str) {
        $str=(" -" + $field + " " + $str)                                                           # append command line flag
        Write-Output $str
    }

}

# startstr | generate startup string for one proc passed by procname
function startstr {
    param($procname)
    $params = "proctype U localtime g T w load schemafile tplogdir"                                 # params to load
    $start = "${env:TORQHOME}\torq.q -procname $procname ${env:KDBSTACKID}"                         # basic command line
    foreach($p in $params.split(" ")) {                                                             # iterate over params
        $a = parameter $procname $p                                                                 # get each param
        $start = ($start + $a)                                                                      # append to start string
    }
    $a = getfield $procname extras                                                                  # get extra fields
    Write-Output ($start + " " + $a)                                                                # output startup string
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
