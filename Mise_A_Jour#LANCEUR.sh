#!/bin/bash
# Mise_A_Jour#LANCEUR.sh
# Copyright (C) 2020 by drehuwann@gmail.com
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theJ
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
#
#DEPENDENCIES : gentoo portage xfce
#USAGE : ./Mise_A_Jour#LANCEUR.sh with normal rights

# Initialisation
xfce4-terminal --working-directory=$MAJ_PREFIX -x sudo sh ./Mise_A_Jour#SCRIPT.sh
