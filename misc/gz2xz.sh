#!/bin/bash
# Convert *.gz to xz using pxz
# __author__: tuan t. pham
# usage: ./gz2xz.sh *.gz

CPUS=${CPUS:=4}
RM=${RM:=0}

for i in $@; do
	OUT_FILE=`echo $i | sed 's/gz$/xz/'`
	echo "Converting $i to $OUT_FILE"
	time zcat $i | pv | pxz -T$CPUS -c9 - > $OUT_FILE
	[ "$RM" -eq 1 ] && (echo "Removing $i"; rm $i)
done
