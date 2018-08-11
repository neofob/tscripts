#!/usr/bin/env bash

# Extract audio track from video files
# Usage: SRC_DIR=/path/to/videos exau.sh
# __author__: tuan t. pham

# Reference: https://gist.github.com/protrolium/e0dbd4bb0f1a396fcb55
# ffmpeg -i test.mp4 -f mp3 -ab 320000 -vn test.mp3

SRC_DIR=${SRC_DIR:=.}
FILE_PATTERN=${FILE_PATTERN=*.mp4}
DEST_DIR=${DEST_DIR:=.}
FORMAT=${FORMAT:=ogg}
BIT_RATE=${BIT_RATE:=320000}
SANITIZE=${SANITIZE:=1}

if [ ! -d $SRC_DIR ]; then
	echo "$SRC_DIR does not exists!"
	exit 1
fi

pushd $SRC_DIR >/dev/null

[ -d $DEST_DIR ] || mkdir -p $DEST_DIR

for f in `ls $FILE_PATTERN`; do
	out_file=`echo $f | sed -e 's/\..*$/.ogg/'`
	# echo "$f $out_file"
	ffmpeg -i $f -f $FORMAT -ab $BIT_RATE -vn $DEST_DIR/$out_file
done

popd >/dev/null
