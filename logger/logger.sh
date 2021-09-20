#!/bin/bash

#Debut arg parser
################################################################################
#define FALSE 1
let "FALSE = 1"
#define TRUE 1
let "TRUE = 0"

#default flags
let "VERBOSE = $FALSE"
let "VERY_VERBOSE = $FALSE"
MOREFLAGS=-pvUDN
#end of default flags

for i in $@
	 #$@ = argv[1..argc]
do
    if [ $i = "-v" ]
    then
	VERBOSE=$TRUE
    fi
    if [ $i = "-vv" ]
    then
	VERY_VERBOSE=$TRUE
	VERBOSE=$TRUE
    fi
done
#Fin arg parser
################################################################################

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
