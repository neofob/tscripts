#!/bin/bash
# Convert *.bz2 to xz using xz
# __author__: tuan t. pham
#
# usage:
#	./bz2xz.sh *.bz2
# OR, to remove .bz file when done
#	RM=1 ./bz2xz.sh *.bz2

OUT_DIR=${OUT_DIR:-$(pwd)}
CPUS=${CPUS:-$(nproc)}
RM=${RM:-0}

for i in "$@"; do
	OUT_FILE=${i/%bz*/xz}
	echo "Converting $i to ${OUTDIR}/${OUT_FILE}"
	time bzcat $i | xz -T$CPUS -c9 - | pv > ${OUT_DIR}/${OUT_FILE}
	[ "$RM" -eq 1 ] && (echo "Removing $i"; rm $i)
done
