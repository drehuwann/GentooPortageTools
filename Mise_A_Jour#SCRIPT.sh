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
# DEPENDENCIES : gentoo portage, eix, eselect
# USAGE : sudo ./Mise_A_Jour#SCRIPT.sh [--nosync] [--pd] [--nokern]
# must be launched as root by a sudoer or wheel group member
##########################################################################

# Check privileges
if [[ "${EUID}" -ne 0 ]]; then
    echo "ERROR: This script must be launched as root."
    echo "Usage: sudo $0 [--nosync] [--pd] [--nokern]"
    exit 1
fi

#Debut arg parser
################################################################################
#define FALSE 1
FALSE=1
#define TRUE 0
TRUE=0

#default flags
NO_SYNC=$FALSE #do not run sync
PD=$FALSE      #powers down computer after run
NK=$FALSE      #no kernel building
#end of default flags

for i in "$@"
do
    case "$i" in
        --nosync)
            NO_SYNC=$TRUE
            ;;
        --pd)
            PD=$TRUE
            ;;
        --nokern)
            NK=$TRUE
            ;;
        *)
            echo "ERROR: Unknown argument: $i"
            echo "Usage: $0 [--nosync] [--pd] [--nokern]"
            exit 1
            ;;
    esac
done
#Fin arg parser
################################################################################

# Commands requiring successful execution
run_command() {
    "$@"
    local status=$?

    if [[ $status -ne 0 ]]; then
        echo "ERROR: Command failed (exit status $status): $*"
        exit "$status"
    fi
}

# Check required commands
for cmd in emerge eix eselect uname readlink cp make; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: Required command not found: $cmd"
        exit 1
    fi
done

# Repository synchronization
if [[ "$NO_SYNC" -ne $TRUE ]]; then
    run_command emaint sync --auto
fi

if [[ "$PD" -ne $TRUE ]]; then
    ASK=(--ask)
else
    ASK=()
fi

# System update
run_command emerge -vuDN "${ASK[@]}" --with-bdeps y --oneshot @world

# Kernel building
################################################################################

if [[ "$NK" -eq "$FALSE" ]]; then

    echo "Checking installed Gentoo kernel sources..."

    # Retrieve the first installed gentoo-sources version from eix
    NEW_KERN_VER=$(
        eix gentoo-sources |
        awk '/Installed versions/ {
            for (i = 3; i <= NF; i++) {
                gsub(/\(.*/, "", $i)
                if ($i ~ /^[0-9]/) {
                    print $i
                    exit
                }
            }
        }'
    )

    if [[ -z "$NEW_KERN_VER" ]]; then
        echo "ERROR: Cannot determine installed gentoo-sources version."
        echo "Check the output of: eix gentoo-sources"
        exit 1
    fi

    echo "Installed gentoo-sources version: $NEW_KERN_VER"

    # Build the eselect kernel name from the Portage version
    # 6.18.64-r1 -> linux-6.18.64-gentoo-r1
    # 6.18.64    -> linux-6.18.64-gentoo
    KERN_BASE="${NEW_KERN_VER%%-r*}"
    KERN_REV=""
    if [[ "$NEW_KERN_VER" == *-r* ]]; then
        KERN_REV="-r${NEW_KERN_VER##*-r}"
    fi
    KERN_NAME="linux-${KERN_BASE}-gentoo${KERN_REV}"

    # Find the exact kernel source name in eselect
    KERN_SYMLINK_NUM=$(
        eselect kernel list |
        awk -v name="$KERN_NAME" '
            $2 == name {
            gsub(/[][]/, "", $1)
            print $1
            exit
        }'
    )

    if [[ -z "$KERN_SYMLINK_NUM" ]]; then
        echo "ERROR: Cannot find kernel source ${KERN_NAME}"
        echo "Available sources:"
        eselect kernel list
        exit 1
    fi

    echo "Selected kernel source entry: $KERN_SYMLINK_NUM"

    # Select the appropriate kernel source
    run_command eselect kernel set "$KERN_SYMLINK_NUM"

    if [[ ! -e /usr/src/linux ]]; then
        echo "ERROR: /usr/src/linux does not exist."
        exit 1
    fi

    SELECTED_SOURCE=$(readlink -f /usr/src/linux) || {
        echo "ERROR: Cannot resolve /usr/src/linux"
        exit 1
    }

    CURRENT_KERNEL=$(uname -r)
    RUNNING_SOURCE=""

    if [[ -e "/lib/modules/${CURRENT_KERNEL}/build" ]]; then
        RUNNING_SOURCE=$(
            readlink -f "/lib/modules/${CURRENT_KERNEL}/build"
        ) || {
            echo "ERROR: Cannot resolve running kernel source."
            exit 1
        }
    fi

    echo "Running kernel: $CURRENT_KERNEL"
    echo "Selected source: $SELECTED_SOURCE"

    # Test whether a kernel rebuild is necessary
    NEED_KERNEL_BUILD=$FALSE

    if [[ -z "$RUNNING_SOURCE" ]]; then
        echo "WARNING: Cannot identify running kernel source."
        NEED_KERNEL_BUILD=$TRUE

    elif [[ "$SELECTED_SOURCE" != "$RUNNING_SOURCE" ]]; then
        echo "A different kernel source tree is selected."
        NEED_KERNEL_BUILD=$TRUE

    else
        echo "Selected kernel sources match the running kernel."
    fi

    if [[ "$NEED_KERNEL_BUILD" -eq "$TRUE" ]]; then

        echo "Preparing to build kernel"

        OLD_CONFIG="/boot/config-${CURRENT_KERNEL}"
        NEW_CONFIG="/usr/src/linux/.config"

        # Always copy the old config, regardless of genkernel or manual build
        if [[ -f "$OLD_CONFIG" ]]; then
            echo "Using kernel config from $OLD_CONFIG"
            run_command cp "$OLD_CONFIG" "$NEW_CONFIG"

        elif [[ -f "$NEW_CONFIG" ]]; then
            echo "WARNING: No previous kernel config found at $OLD_CONFIG"
            echo "Using existing configuration: $NEW_CONFIG"

        else
            echo "ERROR: No kernel configuration available."
            echo "You must configure the kernel manually."
            exit 1
        fi

        # Build kernel
        pushd /usr/src/linux >/dev/null || {
            echo "ERROR: Cannot enter /usr/src/linux"
            exit 1
        }

        # Now choose build method
        if command -v genkernel >/dev/null 2>&1; then

            echo "Using genkernel"

            if [[ "$PD" -eq "$TRUE" ]]; then
                echo "Non-interactive mode (--nomenuconfig)"
                run_command genkernel --oldconfig --nomenuconfig all
            else
                run_command genkernel --oldconfig all
            fi

        else

            echo "genkernel not found."
            echo "Falling back to manual kernel build."

            if [[ "$PD" -eq "$TRUE" ]]; then
                echo "Using olddefconfig because --pd was passed"
                run_command make olddefconfig
            else
                run_command make oldconfig
            fi

            run_command make -j"$(nproc)"
            run_command make modules_install
            run_command make install

            # Update GRUB if available
            if command -v grub-mkconfig >/dev/null 2>&1 &&
               [[ -d /boot/grub ]]; then
                run_command grub-mkconfig -o /boot/grub/grub.cfg
            else
                echo "WARNING: GRUB configuration was not updated."
                echo "Update your bootloader configuration manually."
            fi

        fi

        popd >/dev/null || exit 1

        echo "Kernel build completed successfully."

    else
        echo "No kernel rebuild required."
    fi

else
    echo "Kernel building disabled (--nokern)."
fi

################################################################################
# System cleanup
################################################################################

run_command emerge "${ASK[@]}" --depclean
run_command revdep-rebuild
run_command eclean -d distfiles
run_command eclean -d packages
run_command updatedb

# Power down computer if requested
if [[ "$PD" -ne "$FALSE" ]]; then
    run_command shutdown -Ph now
fi

echo "System maintenance completed successfully."
exit 0
