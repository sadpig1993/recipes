#!/bin/bash
function usage
{
	echo "Usage:${BASH_NAME} [-f] [-d|--date YYYYMMDD] [-t|--time HHMMSS]"
	exit 1
}
    ARGS=`getopt -o fd:t: -l date:,time:,help -- "$@"`  
    [ $? -ne 0 ] && usage
    #set -- "${ARGS}"  
    eval set -- "${ARGS}" 
     
    while [ $# -gt 0 ]
    do  
            case "$1" in 
            -f)  
                    LIST="$1 is set" 
		    echo "$LIST"
                    ;;  
            -d|--date)  
                    date="--date/-d is $2" 
		    echo "$date"
                    shift  
                    ;;  
            -t|--time)  
                    time="--time/-t is $2" 
		    echo "$time"
                    shift  
                    ;;  
            esac  
    shift  
    done 
