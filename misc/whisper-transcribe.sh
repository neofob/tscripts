#!/usr/bin/env bash

WHISPER_MODEL_DIR=${WHISPER_MODEL_DIR:-/mnt/extra/src/whisper.cpp/models}
MODEL=${MODEL:-${WHISPER_MODEL_DIR}/ggml-medium.en.bin}

for f in $(ls *.wav); do
	out_file="${f%%.*}"
	whisper -otxt -l en -m ${MODEL} \
		-f $f -t 4 -of $out_file
done
