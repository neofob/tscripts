#!/bin/bash
# Convert *.bz2 to xz using pxz
# __author__: tuan t. pham
#
# usage:
#	./bz2xz.sh *.bz2
# OR, to remove .bz file when done
#	RM=1 ./bz2xz.sh *.bz2

CPUS=${CPUS:=4}
RM=${RM:=0}

for i in "$@"; do
	OUT_FILE=${i/%bz*/xz}
	echo "Converting $i to $OUT_FILE"
	time bzcat $i | pv | pxz -T$CPUS -c9 - > $OUT_FILE
	[ "$RM" -eq 1 ] && (echo "Removing $i"; rm $i)
done
