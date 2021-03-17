# README.md
Copyright (C) 2020-2021 by drehuwann@gmail.com

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.


DEPENDENCIES : gentoo portage

INSTALL : as user : Add and uncomment the next 2 lines to your ~/.bashrc
#export MAJ_PREFIX="the_absolute_path_where_you_installed_these_files" 
#alias maj="$MAJ_PREFIX/Mise_A_Jour#TTY_LAUNCHER.sh"

USAGES :
under TTY :
      sudo $MAJPREFIX/Mise_A_Jour#SCRIPT.sh [--nosync]
      $MAJPREFIX/Mise_a_Jour#TTY_LAUNCHER.sh [--nosync]
must be launched as root by a sudoer or wheel group member

under xfce :
use Mise_A_Jour#LANCEUR.sh with normal rights

else you can simply use the alias :
     maj [-nosync]
