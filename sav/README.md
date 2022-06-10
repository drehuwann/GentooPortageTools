# README.md
###
# $MAJ_PREFIX/sav/sav.sh
#
# 
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
## 

## DEPENDENCIES :<br>
gentoo portage

## INSTALL :<br>
as user : Add and uncomment the next 2 lines to your ~/.bashrc

<code>#export MAJ_PREFIX="the_absolute_path_where_you_installed_this_dirctory"</code><br>
<code>#alias maj="$MAJ_PREFIX/sav/sav.sh"</code><br>

## USAGES :<br>
### under TTY :<br>
<code>sudo $MAJ_PREFIX/sav/sav.sh "package name" [more packages]</code><br>
<code>$MAJ_PREFIX/Mise_a_Jour#TTY_LAUNCHER.sh [--nosync]</code><br>
must be launched as root by a sudoer or wheel group member

### under xfce :<br>
use <code>$MAJ_PREFIX/Mise_A_Jour#LANCEUR.sh [--nosync]</code> with normal rights

### else :<br>
you can simply use the alias, anyway :<br>
<code>sav "package name" [more packages]</code>
