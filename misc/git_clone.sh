#!/bin/bash
# __author__: tuan t. pham
# git clone a bunch of repos from github
# GIT_BASE=https://github.com/neofob git_clone.sh repo_list
# repo_list example:
# zerofree
# tscripts

GIT_BASE=${GIT_BASE:="https://github.com/neofob"}
REPOS=$( sed 's/\#.*$//' $1 )

for repo in $REPOS; do
	git clone $GIT_BASE/$repo
done
