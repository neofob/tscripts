#!/usr/bin/env bash
# periodically rsync till ctl-c is entered
# INTERVAL=3600 tsync.sh /path/to/src /path/to/des

INTERVAL=${INTERVAL:=3600}
RSYNC_CMD=${RSYNC_CMD:="rsync -av --delete"}

function bailing_out()
{
	echo "Exiting tsync.sh"
	exit 0
}

trap bailing_out SIGINT

while true
do
	echo "$RSYNC_CMD $1 $2"
	$RSYNC_CMD $1 $2
	echo "Going to sleep $INTERVAL seconds"
	sleep $INTERVAL
done
