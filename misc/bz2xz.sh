#!/bin/bash
# Convert *.bz2 to xz using pxz
# __author__: tuan t. pham
# usage: ./bz2xz.sh *.bz2

CPUS=${CPUS:=4}
RM=${RM:=0}

for i in $@; do
	OUT_FILE=`echo $i | sed 's/bz.\+$/xz/'`
	echo "Converting $i to $OUT_FILE"
	time bzcat $i | pv | pxz -T$CPUS -c9 - > $OUT_FILE
	[ "$RM" -eq 1 ] && (echo "Removing $i"; rm $i)
done
