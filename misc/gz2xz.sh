#!/bin/bash
# Convert *.gz to xz using pxz
# __author__: tuan t. pham
# usage: ./gz2xz.sh *.gz

OUT_DIR=${OUT_DIR:=$(pwd)}
CPUS=${CPUS:=$(grep -c processor /proc/cpuinfo)}
RM=${RM:=0}

for i in $@; do
	OUT_FILE=`echo $i | sed 's/gz$/xz/'`
	echo "Converting $i to ${OUT_DIR}/$OUT_FILE"
	time zcat $i | pxz -T${CPUS} -c9 - | pv > ${OUT_DIR}/${OUT_FILE}
	[ "$RM" -eq 1 ] && (echo "Removing $i"; rm $i)
done
