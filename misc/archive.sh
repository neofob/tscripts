#!/bin/bash
# Archive a bunch of files, directories to a .tar.xz file
# __author__: tuan t. pham

help_msg="\e[1;31mUsage:\e[0m $0 <src0 src1...> <output_file.tar.xz>

Tar and compress a bunch of input dirs, files to an a .tar.xz file

__author__: tuan t. pham"

CPUS=${CPUS:=$(grep -c processor /proc/cpuinfo)}
# Set this to 6 if 9 is too slow
COMPRESS_LEVEL=${COMPRESS_LEVEL:=9}

function print_help()
{
	exec echo -e "$help_msg"
}

function process()
{
	time tar cfO - $SRC | pv -s ${SIZE} | pxz -T${CPUS} -c${COMPRESS_LEVEL} - > $DESC
}

function check()
{
	if [ $# -lt 2 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
		print_help
		exit 0
	fi

	PARAMS_NO=$#
	SRC="${*:1:$# - 1}"
	DESC="${*: -1}"
	SIZE=$(du -cbs ${SRC} | tail -n 1 | awk '{print $1}')

	echo "Number of parameters = $PARAMS_NO"
	echo "SRC=$SRC"
	echo "DESC=$DESC"
	echo "CPUS=$CPUS"
}

check "$@"
process
