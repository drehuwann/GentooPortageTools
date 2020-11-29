#!/bin/bash

# Donner le fichier à root
sudo chown root Mise_A_Jour#SCRIPT.sh

# mettre le bit setuid
sudo chmod +s Mise_A_Jour#SCRIPT.sh

layman -S
eix-sync
emerge -avuDN --with-bdeps y @world
emerge -a --depclean
revdep-rebuild
eclean -d distfiles
updatedb

