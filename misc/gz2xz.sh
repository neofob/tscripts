#!/bin/bash
# Convert *.gz to xz using pxz
# __author__: tuan t. pham
# usage: ./gz2xz.sh *.gz

OUT_DIR=${OUT_DIR:-$(pwd)}
CPUS=${CPUS:-$(nproc)}
RM=${RM:-0}

for i in $@; do
	OUT_FILE=`echo $i | sed 's/gz$/xz/'`
	echo "Converting $i to ${OUT_DIR}/$OUT_FILE"
	time zcat $i | xz -T${CPUS} -c9 -M $(echo "$(nproc)*1.5/1" | bc)G - | pv > ${OUT_DIR}/${OUT_FILE}
	[ "$RM" -eq 1 ] && (echo "Removing $i"; rm $i)
done
