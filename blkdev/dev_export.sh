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
CPUS=${CPUS:=`grep -c processor /proc/cpuinfo`}
OUT_IMG=disk.img.xz
ZF=${ZF:=0}

function log()
{
	if [ "$DEBUG" = 1 ]; then
		eval "echo $@"
	fi
}

function help_msg()
{
	echo "Usage: $0 [-h] [-z] <-d BLOCK_DEV> [-c CPUS] <-o OutputDiskImage.img.xz>"
	echo
	echo -e "Zerofree a block device, compress it to an output file"
	echo
	echo -e "\t-h This help message"
	echo
	echo -e "\t-z Enable zerofree to run before dd"
	echo -e "\t   DEFAULT is not set"
	echo
	echo -e "\t-d Block device source"
	echo
	echo -e "\t-c Number of cpu cores to be used for compression"
	echo -e "\t   DEFAULT is the number of available cpu cores"
	echo
	echo -e "\t-o Output file name"
	echo
	echo "Other required tools: zerofree, pv, pxz"
	echo
	echo "__author__: tuan t. pham"
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
	[ "$ZF" = 1 ] && sudo zerofree $DEV

	if [ -b "$DEV" ]; then
		sudo dd if=$DEV bs=1M | pv | pxz -T$CPU -c9 - > $OUT_IMG
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
		parse_opts $@
	fi
}

main $@
