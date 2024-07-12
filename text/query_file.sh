#!/usr/bin/env bash
# loop through all files to query privategpt with instruction based on instruct.yml
# Use pgpt_query.py
# pip install pgpt_python
# or install from its source, pip install -e .
# Sample instruct.yml
#---
##instruct.yml
#instruct:
#  url: "localhost"
#  port: 8001
#  # 8 hours
#  timeout: 28800
#  #prompt_file: NONE
#  #  filename: prompts.yaml
#  #  index: 42
#  system: "You are an expert in macroeconomics and world geopolitics."
#  instruct: "Summarize the following conversation into 5 points."
#  #textFile:
#  outputPostfix: "-Summary"
#  outputExtension: "md"

DEST_DIR=${DEST_DIR:-.}
OUTPUT_DIR=$(realpath $DEST_DIR)
INST=${INST:-$HOME/.config/instruct.yml}
for f in "$@"; do
	base_fn=$(basename $f)
	# remove last 12 chars in filename
	# base_fn="${base_fn::-12}"
	outfile="${base_fn%%.*}-Summary.md"
	#echo "$outfile"
	echo "Processing $f"
	echo "### Summary" > $OUTPUT_DIR/$outfile
	time pgpt_query.py -c ${INST} -i $f | fmt --width=80 --split-only | awk '{$1=$1;print}' >> $OUTPUT_DIR/$outfile
	echo "Done."
done
