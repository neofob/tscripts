#!/bin/bash
# Check one or more REs from an input file
# __author__: tuan t. pham

# usage: re_check.sh input.re data.txt

# sample input
# # comment
# reMATCH\tCrap\tCrap\tValue

if [ $# -ne 2 ]; then
	echo "Incorrect input!"
	echo "$0 input.re data.txt"
	exit 1
fi

for i in `grep -v "^#" $1`; do
	echo "Check for RE $i"
	grep -e "^$i\\s" $2 | awk '{print $1"\t"$4}'
	echo
done
