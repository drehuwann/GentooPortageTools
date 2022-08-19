#!/bin/bash
# Mise_A_Jour#SCRIPT.sh
# Copyright (C) 2020 by drehuwann@gmail.com
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.
##########################################################################
# DEPENDENCIES : gentoo portage
# USAGE : sudo ./Mise_A_Jour#SCRIPT.sh [--nosync] [--pd]
# must be launched as root by a sudoer or wheel group member
##########################################################################

# Donner le fichier à root
chown root $0
# mettre le bit setuid
chmod +s $0
# $0 = (this)filename with path

#Debut arg parser
################################################################################
#define FALSE 1
let "FALSE = 1"
#define TRUE 0
let "TRUE = 0"

#default flags
let "NO_SYNC = $FALSE"
let "PD = $FALSE"
#end of default flags

for i in $@
	 #$@ = argv[1..argc]
do
    if [ $i = "--nosync" ]
    then
	NO_SYNC=$TRUE
    fi
    if [ $i = "--pd" ]
    then
    	PD=$TRUE
    fi
done
#Fin arg parser
################################################################################

if [ "$NO_SYNC" -ne $TRUE ]
   #if [ "$NO_SYNC" -ne 0 ] 
then
    layman -S
    eix-sync
fi

emerge -avuDN --with-bdeps y @world

NEW_KERN_VER=(`eix gentoo-sources | grep 'Installed versions' | awk '{print $3}' | cut -d\( -f1`)
CURRENT_KERN_VER=(`uname -r | cut -d- -f1`)

if [ $NEW_KERN_VER != $CURRENT_KERN_VER ]
then
    KERN_SYMLINK_NUM=(`eselect kernel list | grep -- -$NEW_KERN_VER- | awk '{print $1}' | cut -d] -f1 | cut -d[ -f2`)
    eselect kernel set $KERN_SYMLINK_NUM
    genkernel all
fi
    
emerge -a --depclean
revdep-rebuild
eclean -d distfiles
eclean -d packages
updatedb

#remove root ownership after use
################################################################################
# $USER is the developer ;-), working in USER space ...
################################################################################
# If you aren't a dev, you should comment this next line ...
chown $MAJ_USER $0


if [ "$PD" -ne $FALSE ]
then
    shutdown -P now
fi
