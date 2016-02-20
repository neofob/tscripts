#!/bin/bash

# If your hard drive is showing sign of age, get a new one and back it up, cp
# ./dev_sync.sh -f -s /opt/photos -m /tmp/Backup -d /dev/sdc1
# W/o formatting:
# ./dev_sync.sh -s /opt/photos -m /tmp/Backup -d /dev/sdc1
# -f: format
# -s: source
# -m: mount point
# -d: block device
#
# __author__: tuan t. pham <tuan at vt dot edu>

DEBUG=${DEBUG:=0}
DRY_RUN=${DRY_RUN:=0}
MNT=${MNT:="/tmp/dest"}
SRC=${SRC:="/media/`whoami`/Backup"}
DEV=${DEV:="/dev/sdc1"}
SYNC_CMD=${SYNC_CMD:="rsync -av --delete"}
MKFS=${MKFS:="mkfs.ext4 -F -m 0 -L"}
MNT_CMD=${MNT_CMD:="mount -t ext4"}
LABEL=${LABEL:="Backup"}
OPTS=":fL:s:m:d:h"

function log()
{
	if [ "$DEBUG" = 1 ]; then
		eval "echo $@"
	fi
}

function var_dump()
{
	VAR_LIST=`grep -o "^[A-Z_]\+" $0`
	echo $VAR_LIST
	for v in $VAR_LIST; do
		eval "echo $v=\$$v"
	done
	echo "FORMAT=$FORMAT"
}


function print_help()
{
	echo "Usage: $0 [-f|-L LABEL] <-s SRC> [-m MOUNT_POINT] <-d DEV>"
	echo -e "\tCopy your aging data to a [new] filesystem"
	echo
	echo -e "Examples:"
	echo -e "\t1) Create a new fs on /dev/sdc1 and copy all data from /opt/photos to it"
	echo -e "\t\t$ $0 -f -s /opt/photos -d /dev/sdc1"
	echo
	echo -e "\t2) Sync up data to an existing partition"
	echo -e "\t\t$ $0 -s /opt/photos -d /dev/sdc1"
}

function parse_opts()
{
	while getopts $OPTS opt; do
		case $opt in
			f)
				log "Option -f is set"
				FORMAT="1"
				;;
			s)
				log "Option -s is set with $OPTARG"
				SRC=$OPTARG
				;;
			m)
				log "Option -m is set with $OPTARG"
				MNT=$OPTARG
				;;
			d)
				log "Option -d is set with $OPTARG"
				DEV=$OPTARG
				;;
			L)
				log "Option -L is set with $OPTARG"
				LABEL=$OPTARG
				;;
			h)
				log "Option -h is set"
				print_help
				if [ "$DEBUG" = 1 ]; then
					var_dump
				fi
				exit 1
				;;
			\?)
				echo "Invalid option(s)"
				print_help
				exit 1
				;;
		esac
	done
	}

function process_var()
{
	if [ "$DRY_RUN" = 1 ]; then
		echo "Dry-run...commands would be executed"
		if [ "$FORMAT" = 1 ]; then
			echo "$MKFS $LABEL $DEV"
		fi
		echo "mkdir -p $MNT"
		echo "$MNT_CMD $DEV $MNT"
		echo "$SYNC_CMD $SRC/ $MNT/"
	else
		if [ "$FORMAT" = 1 ]; then
			echo "Creating ext4 fs..."
			eval "$MKFS $LABEL $DEV"
		fi

		echo
		echo "Mounting $DEV on $MNT"
		[ ! -d "$MNT" ] || mkdir -p $MNT
		eval "$MNT_CMD $DEV $MNT"
		echo "Copy data from $SRC to $MNT"
		eval "$SYNC_CMD $SRC/ $MNT/"
	fi
}

function main()
{
	parse_opts "$@"
	process_var
}

main "$@"
