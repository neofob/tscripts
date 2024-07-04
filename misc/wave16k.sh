#!/usr/bin/env bash

# Extract audio track from video files
# Usage: SRC_DIR=/path/to/videos exau.sh
# __author__: tuan t. pham

# Reference: https://github.com/ggerganov/whisper.cpp
# ffmpeg -i test.mp4 -ar 16000 -ac 1 -c:a pcm_s16le test.wav

SRC_DIR=${SRC_DIR:-.}
FILE_PATTERN=${FILE_PATTERN:-'*.mp4 *.webm *.mkv'}
DEST_DIR=${DEST_DIR:-.}
FORMAT=${FORMAT:-wav}

# This works for Ubuntu/Debian where the 1st user is 1000:1000
USER_ID=${USER_ID:=1000}
GROUP_ID=${GROUP_ID:=1000}

DRY_RUN=${DRY_RUN:-0}
CPUS=${CPUS:-$(nproc)}

if [ ! -d $SRC_DIR ]; then
	echo "$SRC_DIR does not exists!"
	exit 1
fi

pushd $SRC_DIR >/dev/null

[ -d $DEST_DIR ] || mkdir -p $DEST_DIR

for p in $FILE_PATTERN; do
	for f in $(ls $p); do
		tmp=$(echo $f | sed -e "s/ /_/g" )
		out_file="${tmp%%.*}.${FORMAT}"
		# echo "$f $out_file"
		ffmpeg -i $f -f $FORMAT -ar 16000 -ac 1 -c:a pcm_s16le $DEST_DIR/$out_file
	done
done

chown -R $USER_ID:$GROUP_ID $DEST_DIR

popd >/dev/null

