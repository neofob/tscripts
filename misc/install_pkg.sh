#!/bin/bash
# __author__: tuan t. pham
# reference: Bunsen Labs install script
# https://github.com/BunsenLabs/bunsen-netinstall
#
# install debian packages from a file
# usage: ./install_pkg.sh package_list

# Update the package list only once at the beginning for efficiency
sudo apt-get update

# Use awk to remove comments and feed the result directly into xargs for installation
awk '!/^#/' $1 | sudo xargs -r -n 10 apt-get install -yq
