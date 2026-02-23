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
# USAGE : sudo ./Mise_A_Jour#SCRIPT.sh [--nosync] [--pd] [--nokern]
# must be launched as root by a sudoer or wheel group member
##########################################################################

# Donner le fichier à root
chown root $0
# mettre le bit setuid
chmod +s $0
# $0 = (this)filename with path
cleanup() {
    echo "Cleaning up setuid bit..."
    chmod -s "$0"
    chown "$MAJ_USER" "$0"
}
trap 'cleanup' EXIT INT TERM

#Debut arg parser
################################################################################
#define FALSE 1
let "FALSE = 1"
#define TRUE 0
let "TRUE = 0"

#default flags
let "NO_SYNC = $FALSE" #do not run sync
let "PD = $FALSE"      #powers down computer after run
let "NK = $FALSE"      #no kernel building
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
    if [ $i = "--nokern" ]
    then
    	NK=$TRUE
    fi
done
#Fin arg parser
################################################################################

if [ "$NO_SYNC" -ne $TRUE ]
   #if [ "$NO_SYNC" -ne 0 ] 
then
    emaint sync --auto
fi

if [ "$PD" -ne $TRUE ]
then
    ASK="--ask"
fi

emerge -vuDN $ASK --with-bdeps y --oneshot @world

NEW_KERN_VER=(`eix gentoo-sources | grep 'Installed versions' | awk '{print $3}' | cut -d\( -f1`)
REV_FIELD=$(echo "$NEW_KERN_VER" | cut -d- -f2)
CURRENT_KERN_VER=(`uname -r | cut -d- -f1`)

THIRD_FIELD=(`uname -r | cut -d- -f3`)
if [[ "$NK" -eq "$FALSE" ]] && \
   [[ "$NEW_KERN_VER" != "$CURRENT_KERN_VER" || "$THIRD_FIELD" != "$REV_FIELD" ]]
then
    echo Preparing to build kernel
    KERN_SYMLINK_NUM=(`eselect kernel list | grep -- -$NEW_KERN_VER | cut -d] -f1 | cut -d[ -f2`)
    eselect kernel set $KERN_SYMLINK_NUM
    pushd /usr/src/linux
    OLD_CONFIG="/boot/config-$(uname -r)"
    NEW_CONFIG="/usr/src/linux/.config"
    # Always copy the old config, regardless of genkernel or manual build
    if [[ -f "$OLD_CONFIG" ]]; then
        echo "Using kernel config from $OLD_CONFIG"
        cp "$OLD_CONFIG" "$NEW_CONFIG"
    else
        echo "ERROR: No kernel config found at $OLD_CONFIG"
        echo "You must configure the kernel manually."
        popd
        exit 1
    fi
    # Now choose build method
    if command -v genkernel >/dev/null 2>&1; then
        if [ "$PD" -eq $TRUE ]; then
            echo "Using genkernel in non-interactive mode (--nomenuconfig)"
            genkernel --oldconfig --nomenuconfig all
        else
            genkernel --oldconfig all
        fi
    else
        if [ "$PD" -eq $TRUE ]; then
            echo "Using olddefconfig because --pd was passed"
            make olddefconfig
        else
            make oldconfig
        fi
        make
        make modules_install
        make install
    fi
    popd
fi

emerge $ASK --depclean
revdep-rebuild
eclean -d distfiles
eclean -d packages
updatedb

if [ "$PD" -ne $FALSE ]
then
    shutdown -Ph now
fi
