#!/usr/bin/env bash
# Quick script to convert an old whisper data to a new whisper data with new
# data schemea
# SCHEMA="1m:365d" whisper-convert.sh whisper0.wsp /path/to/whisper.wsp
# TODO: Use https://github.com/jjneely/buckytools
# tuan t. pham

set -e

TMP_DIR=${TMP_DIR:=/tmp}
TMP_FILE=${TMP_FILE:=${RANDOM}_$(date +%s).wsp}
OUTFILE=${TMP_DIR}/${TMP_FILE}

SCHEMA=${SCHEMA:="10s:365d"}

echo $TMP_DIR/$TMP_FILE

for f in $@; do
	echo "Processing whisper file $f"
	whisper-create.py --sparse ${OUTFILE} ${SCHEMA}
	# should put an flock here
	whisper-fill.py $f ${OUTFILE}
	mv ${OUTFILE} $f
done
