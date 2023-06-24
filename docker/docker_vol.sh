#!/usr/bin/env bash
# save/load a bunch of docker volumes
# reference: https://github.com/moby/moby/issues/32263
# __author__: tuan t. pham

red="\e[1;31m"
yellow="\e[1;33m"
end="\e[0m"

OPTS=":o:l:n:c:h"
VOLS=${VOLS:=$(docker volume ls -q)}
DEBUG=${DEBUG:=0}
CPUS=${CPUS:=$(grep -c processor /proc/cpuinfo)}
COMPRESSION_LEVEL=6
OUTDIR=${OUTDIR:=$PWD}
# the docker image must have: tar, xz that supports compression
DOCKER_IMG=${DOCKER_IMG:=neofob/linux-utils:latest}

help_msg="${red}Usage:${end} $(basename $0) OPTIONS..
Save or load docker volumes

${yellow}Options:${end}
	-h
	This help message

	-o DIR
	Save volumes to DIR, volumes are in vol_name.tar.xz format
	DEFAULT: $OUTDIR

	-l DIR
	Load volumes from DIR, volumes are in *.tar.xz format
	DEFAULT: $OUTDIR

	-n CPUS
	Number of cpu cores to be used for compression.
	DEFAULT: $CPUS

	-c COMPRESSION_LEVEL
	Compression level.
	DEFAULT: $COMPRESSION_LEVEL

__author__: tuan t. pham

ref: https://github.com/moby/moby/issues/32263"

function dump_vars()
{
	VAR_LIST="OPTS DEBUG OUTDIR VOLS COMPRESSION_LEVEL CPUS"
	for e in $VAR_LIST; do
		d="$e"
		d=`eval echo "\\$$d"`
		echo "$e=$d"
	done
}

function help_msg()
{
	exec echo -e "$help_msg"
}

function log()
{
	if [ "$DEBUG" = 1 ]; then
		echo "$*"
	fi
}

function parse_opts()
{
	while getopts $OPTS opt; do
		case $opt in
			l)
				log "Setting loading files from directory $OPTARG"
				LOAD_DIR=$OPTARG
				;;
			o)
				log "Setting the OUTDIR to \'$OPTARG\'"
				OUTDIR=$OPTARG
				[ -d "$OUTDIR" ] || mkdir -p $OUTDIR
				;;
			n)
				log "Setting the number of cpus to $OPTARG"
				CPUS=$OPTARG
				;;
			c)
				log "Setting compression level $OPTARG"
				COMPRESS_LEVEL=$OPTARG
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

# docker_vol_save
function docker_vol_save()
{
	for v in ${VOLS}; do
		echo "Saving docker volume $v"
		CMD="docker run -it --rm -v $v:/vol -w /vol -v $OUTDIR:/tmp/outdir:rw \
			$DOCKER_IMG archive.sh . /tmp/outdir/$v.tar.xz"
		log "$CMD"
		eval "$CMD"
		echo
	done
}

# docker_vol_load DIR
function docker_vol_load()
{
	VOL_FILES=$(ls $1/*.tar.xz)
	for f in $VOL_FILES; do
		v=$(basename $f | sed -s 's/.tar.xz//')
		echo "Loading docker volume $v"
		CMD="docker run --rm -v $v:/vol -w /vol -i busybox tar xJ < $f"
		log "$CMD"
		eval "$CMD"
	done
}

function main()
{
	if [ "$1" = "--help" ]; then
		help_msg
		exit 0
	fi

	parse_opts "$@"

	[ "$DEBUG" = 1 ] && dump_vars
	[ "$LOAD_DIR" ] && docker_vol_load $LOAD_DIR && exit 0
	docker_vol_save
}

main "$@"
