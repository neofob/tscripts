#!/bin/bash
# __author__: tuan t. pham
# install debian packages from a file
# install_pkg.sh package_list

sudo apt-get update
sudo apt-get install -yq $( sed 's/\#.*$//' $1 )
