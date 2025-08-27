#!/usr/bin/env bash

WHISPER_MODEL_DIR=${WHISPER_MODEL_DIR:-/mnt/extra/models/whisper.cpp}
MODEL=${MODEL:-ggml-large-v3-turbo.bin}
MODEL_PATH=$WHISPER_MODEL_DIR/$MODEL

SRC_DIR=${SRC_DIR:-.}
DEST_DIR=${DEST_DIR:-.}

OUTPUT_DIR=$(realpath $DEST_DIR)

for f in $(ls ${SRC_DIR}/*.wav); do
	base_fn=$(basename $f)
	out_file="${base_fn%%.*}"
	echo $out_file
	whisper-cli -otxt -l en -m ${MODEL_PATH} \
		-f $f -t 4 -of $OUTPUT_DIR/$out_file
done
