#!/bin/bash
# zerofree a block device (assumed that it's ext3/4 format)
# dd and compress it to .xz file
# __author__: tuan t. pham <tuan at vt dot edu>

# block device @ /dev/loop0, /dev/nbd0, /dev/sda1...etc.
# zerofree /dev/loop0
# dd if=/dev/loop0 bs=1M | pv | pxz -T4 -c9 - > disk.img.xz
# usage:
# ./dev_export.sh -d /dev/sdc1 -c 4 -o sdc1.img.xz

OPTS=":zd:c:o:h"

DEBUG=${DEBUG:=0}
DEV=""
CPUS=${CPUS:=$(grep -c processor /proc/cpuinfo)}
OUT_IMG=disk.img.xz
ZF=${ZF:=0}

help_msg="\e[1;31mUsage:\e[0m $0 [-h] [-z] <-d BLOCK_DEV> [-c CPUS] <-o OutputDiskImage.img.xz>

Zerofree a block device, compress it to an output file

	-h This help message

	-z Enable zerofree to run before dd
	   DEFAULT: not set

	-d Block device source; e.g, /dev/sda, /dev/zram1, /dev/loop0

	-c Number of cpu cores to be used for compression
	   DEFAULT: number of cpu cores in the system

	-o Output file name
	  DEFAULT: $OUT_IMG

\e[1;31mExample(s):\e[0m
	0) Export /dev/sdb1 to sdb.img.xz (zerofree, use 4 core to compress)
	$ $0 -z -d /dev/sdb1 -c 4 -o sdb.img.xz

	1) Export /dev/loop0, no zerofree
	$ $0 -d /dev/loop0 -o disk.img.xz

\e[1;33mOther required tools:\e[0m zerofree, pv, pxz

\e[1;33mNotice:\e[0m This script should be run as \e[1;31mroot\e[0m in order to have access to the block device(s).

__author__: tuan t. pham"

function log()
{
	if [ "$DEBUG" = 1 ]; then
		eval echo "$@"
	fi
}

function help_msg()
{
	exec echo -e "$help_msg"
}

function parse_opts()
{
	while getopts $OPTS opt; do
		case $opt in
			z)
				log "Setting zerofree flag"
				ZF=1
				;;
			d)
				log "Setting block device $OPTARG"
				DEV=$OPTARG
				;;
			c)
				log "Setting number of cpus $OPTARG"
				CPUS=$OPTARG
				;;
			o)
				log "Setting output file $OPTARG"
				OUT_IMG=$OPTARG
				;;
			h)
				log "Setting -h option"
				help_msg
				exit 0
				;;
			\?)
				echo "Invalid option(s)"
				help_msg
				exit 1
				;;
		esac
	done
}

function process()
{
	[ "$ZF" = 1 ] && zerofree $DEV

	if [ -b "$DEV" ]; then
		dd if=$DEV bs=1M | pv | pxz -T$CPU -c9 - > $OUT_IMG
	else
		echo "$DEV is not a block device"
		exit 1
	fi
}

function main()
{
	if [ $# -eq 0 ]; then
		help_msg
	else
		parse_opts "$@"
	fi
}

main "$@"
