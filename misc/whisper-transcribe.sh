#!/usr/bin/env bash

WHISPER_MODEL_DIR=${WHISPER_MODEL_DIR:-/mnt/extra/src/whisper.cpp/models}
MODEL=${MODEL:-${WHISPER_MODEL_DIR}/ggml-medium.en.bin}

SRC_DIR=${SRC_DIR:-.}
DEST_DIR=${DEST_DIR:-.}

OUTPUT_DIR=$(realpath $DEST_DIR)

for f in $(ls ${SRC_DIR}/*.wav); do
	base_fn=$(basename $f)
	out_file="${base_fn%%.*}"
	#echo $out_file
	whisper -otxt -l en -m ${MODEL} \
		-f $f -t 4 -of $OUTPUT_DIR/$out_file
done
