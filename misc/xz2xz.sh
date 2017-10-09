#!/bin/bash
# Recompress a tar.xz file to xz with highest compression level:9
# __author__: tuan t. pham
# usage: ./xz2xz.sh *.xz

CPUS=${CPUS:=$(grep -c processor /proc/cpuinfo)}
RM=${RM:=0}
TMP_DIR=${TMP_DIR:=/tmp}

for i in "$@"; do
	OUT_FILE=`echo $i | sed 's/\.tar\.xz$/_1\.tar\.xz/'`
	echo "Converting $i to $TMP_DIR/$OUT_FILE"
	time xzcat $i | pv | pxz -T$CPUS -c9 - > $TMP_DIR/$OUT_FILE
	if [ "$RM" -eq 1 ]; then
		echo "Replacing $i with new recompressed $OUT_FILE"
		rm $i && mv $TMP_DIR/$OUT_FILE $i
	fi
done
