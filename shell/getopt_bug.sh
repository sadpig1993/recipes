#!/bin/bash
if [ $# -lt 1 ]
then
	echo "opt num is 0";
else
	TEMP=`getopt -o fd:t: -l date:,time: --"$@"`
	if [ $? != 0 ]; then echo "Terminating..." >&2; exit 1; fi
	eval set -- "${TEMP}"
	while [ $# -gt 0 ] ; do
		case "$1" in
			-f) echo "$1 is set";;
			-d|--date) echo "Option d/date,argument $2 ";shift;;
			-t|--time) echo "Option t/time,argument $2 ";shift;;
			*) echo "Internal error!";exit 1;;
		esac
		shift
	done
fi
