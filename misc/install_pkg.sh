#!/bin/bash
# __author__: tuan t. pham
# reference: Bunsen Labs install script
# https://github.com/BunsenLabs/bunsen-netinstall
#
# install debian packages from a file
# install_pkg.sh package_list

sudo apt-get update
sudo apt-get install -yq $( sed 's/\#.*$//' $1 )
