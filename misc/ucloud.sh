#!/bin/bash -

PATTERN=${PATTERN:=*.deb}
LOCAL_DIR=${LOCAL_DIR:=/tmp}
# replace these hostnames with yours
REMOTE_HOST=${REMOTE_HOST:="cloud1 cloud2 cloud3"}
REMOTE_DIR=${REMOTE_DIR:=/tmp}
for d in $REMOTE_HOST; do
	echo "Uploading files of pattern $PATTERN to $d"
	scp $LOCAL_DIR/$PATTERN $d:/$REMOTE_DIR
done
