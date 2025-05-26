#!/usr/bin/env bash

DATE=$(date +%Y-%m%d)
PREFIX=${PREFIX:-$DATE}

OUTPUT_LIST=${OUTPUT_LIST:-"$PREFIX-var_logs.list"}
OUTPUT_FILE=${OUTPUT_FILE:-"$PREFIX-var_logs.tar.xz"}
OUTPUT_DIR=${OUTPUT_DIR:-"."}
COMPRESSION_PROG="xz -T0 -c9"
FILE_PATTERN=${FILE_PATTERN:-"/var/log/*.log"}

COMMAND="ls -R ${FILE_PATTERN}"

echo "Getting the list of var log files"
time $COMMAND > $OUTPUT_DIR/${OUTPUT_LIST}

echo "Compressing the list of files"
time tar cvf $OUTPUT_DIR/$OUTPUT_FILE --use-compress-program="$COMPRESSION_PROG" $(cat $OUTPUT_DIR/$OUTPUT_LIST)
