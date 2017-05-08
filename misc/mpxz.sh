#!/usr/bin/env bash
# __author__: tuan t. pham <tuan at vt dot edu>

OPTS=":n:c:d:h"
DEBUG=${DEBUG:=0}

PREFIX=archive
MP_N=${MP_N:=1}
COMP_LEVEL=${COMP_LEVEL:=6}
SRC=""
LOCAL_MP_NODES=( $MP_NODES )
MP_SIZE=${#LOCAL_MP_NODES[@]}

args=""

red="\e[1;31m"
yellow="\e[1;33m"
end="\e[0m"

help_msg="${red}Usage:${end} $0 [-n N] [-c C] <-d output_directory> <files..directory..>
Poor-man distributed tar/pxz compression

${yellow}Situation:${end}
	0. Many machines share the same fast distributed/parallel filesystem
	1. We need to compress a bunch of files/directories as quick as possible

${yellow}Example:${end}
	mpxz.sh -n N -c C -d output_directory file0.dat file2.dat dir0 dir1 dir2

	${yellow}N${end} Number of machines to be used; should be <= MP_NODES
	${yellow}C${end} Compression level 0-9; default 6
	${yellow}output_directory${end} relative path or absolute path from
	home directory of MP_USER@MP_NODES

Predefined environment variables:
${yellow}MP_USER${end} default user to login; example: vagrant
${yellow}MP_NODES${end} list of nodes; example: node0, node1, node2
${yellow}SSH_KEY${end} ssh key; default is at ~/.ssh/id_rsa

This script assumes that the list of files, directories are roughly about
the same size. Hence, the workload is equally distributed among the machines.

__author__: tuan t. pham"

function help_msg()
{
	exec echo -e "$help_msg"
}

function log()
{
	if [ "$DEBUG" = 1 ]; then
		eval echo "$@"
	fi
}


function parse_opts()
{
	while getopts $OPTS opt; do
		case $opt in
			n)
				log "Setting number of machines to $OPTARG"
				MP_N=$OPTARG
				;;
			c)
				log "Setting the compression level to $OPTARG"
				COMP_LEVEL=$OPTARG
				;;
			d)
				log "Setting output directory $OPTARG"
				OUT_DIR=$OPTARG
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
		shift $((OPTIND-1))
	done

	# Check for predefined environment variables
	if [ -z "$MP_NODES" ]; then
		echo "Environment variable MP_NODES is not defined"
		exit 1
	fi

	if [ -z "$MP_USER" ]; then
		echo "Environment variable MP_USER is not defined"
		exit 1
	fi
	args="$@"
}

function process()
{
	PREFIX=$PREFIX-"`date "+%Y-%m%d"`"
	log "MP_SIZE = $MP_SIZE"
	pivot=1
	count=$#
	if [ `echo "$count%$MP_SIZE" | bc` -eq 0 ]; then
		step=`echo $count/$MP_SIZE | bc`
	else
		# Round to the next divisible number by MP_SIZE
		step=`echo "($count + $MP_SIZE- $count%$MP_SIZE)/$MP_SIZE" | bc`
	fi
	log "count = $count MP_N = $MP_N"
	log "step = $step pivot = $pivot"
	#mkdir -p $OUT_DIR
	for p in $MP_NODES; do
		# Do the math here
		SRC="${*:$pivot:$step}"
		DESC="${OUT_DIR}/${PREFIX}_${p}.tar.xz"
		if [ "$SRC" = "" ]; then
			break;
		fi
		echo "Calling ssh on $p $SRC $DESC"
		# Sort out the background process, barrier..etc. later
		# ssh -i $SSH_KEY $MP_USER@$p "tar cfO - $SRC | pxz -c$COMPRESS_LEVEL - > $DESC" &
		pivot=$((( pivot + step )))
	done
}

function main()
{
	if [ $# -eq 0 ]; then
		help_msg
	else
		log "Total number of orginal arguments = $#"
		parse_opts "$@"
		process $args
	fi
}

main "$@"
