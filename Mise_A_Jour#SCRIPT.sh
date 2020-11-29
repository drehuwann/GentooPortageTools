#!/bin/bash


# Donner le fichier à root
sudo chown root Mise_A_Jour#SCRIPT.sh

# mettre le bit setuid
sudo chmod +s Mise_A_Jour#SCRIPT.sh

#define FALSE 1
let "FALSE = 1"

#define TRUE 1
let "TRUE = 0"


#Debut arg parser

NO_SYNC=$FALSE
#default value if no args

for i in $@
	 #$@ = argv[1..argc]
do
    if [ $i="--nosync" ]
    then
	NO_SYNC=$TRUE
    fi
done
#Fin arg parser

if [ "$NO_SYNC" -ne $TRUE ]
   #if [ "$NO_SYNC" -ne 0 ] 
   then
       layman -S
       eix-sync
fi

emerge -avuDN --with-bdeps y @world
emerge -a --depclean
revdep-rebuild
eclean -d distfiles
updatedb
