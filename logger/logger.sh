#!/bin/bash

help() {
    echo . logger.sh : utility to help debugging and fixing gentoo\'s emerge conflicts.
    echo .*****************************************************************************
    echo Usage : ./logger.sh [-v,-vv,-h]. Note : these parameters are not cumulable.
    echo Parameters :
    echo .   -v  : verbose. appends --verbose-conflicts to emerge -puDN
    echo .   -vv : very verbose : appends also --debug ...
    echo .   -h  : displays this help and exit.
    exit
}

#Debut arg parser
################################################################################
#define FALSE 1
let "FALSE = 1"
#define TRUE 1
let "TRUE = 0"

#default flags
let "VERBOSE = $FALSE"
let "VERY_VERBOSE = $FALSE"
MOREFLAGS=-puDN
#end of default flags

for i in $@
	 #$@ = argv[1..argc]
do
    if [ $i = "-v" ]
    then
	VERBOSE=$TRUE
    else
	if [ $i = "-vv" ]
	then
	    VERY_VERBOSE=$TRUE
	    VERBOSE=$TRUE
	else
	    if [ $i = "-h" ] || [ $i != "" ]
	    then
		help
	    fi
	fi
    fi
done
################################################################################
#Fin arg parser

if [ "$VERBOSE" -eq $TRUE ]
then
    MOREFLAGS="${MOREFLAGS} --verbose-conflicts"
fi

if [ "$VERY_VERBOSE" -eq $TRUE ]
then
    MOREFLAGS="${MOREFLAGS} --debug"
fi

echo "emerge $MOREFLAGS --with-bdeps y @world 1>./log.txt 2>./logerr.txt"
emerge $MOREFLAGS --with-bdeps y @world 1>./log.txt 2>./logerr.txt
less ./log.txt
less ./logerr.txt
