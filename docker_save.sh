#!/bin/bash
# __author__: tuan t. pham

# Description: a glorious shell script to save the typing of
# for i in `docker images | tail -n +2...;do docker save $i | xz ...>;done
# This script will save your docker image to a .tar.xz file

# To load the saved image:
# $ xzcat debian_jessie.tar.xz | docker load

# Define your own filter command to filter out the output of `docker images`
FILTER=${FILTER:="grep -vi \"^<None>\""}
CPUS=${CPUS:=`grep -c processor /proc/cpuinfo`}

DEF_IMG_CMD="docker images | tail -n +2 | $FILTER | awk '{print \$1\":\"\$2}'"
IMG_CMD=${IMG_CMD:=$DEF_IMG_CMD}

OUTDIR=${OUTDIR:=.}

# see https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
# the color code snippet is from https://github.com/docker/docker @ docker/contrib/check-config.sh
declare -A colors=(
	[black]=30
	[red]=31
	[green]=32
	[yellow]=33
	[blue]=34
	[magenta]=35
	[cyan]=36
	[white]=37
)
# Ex:
# color red
# echo something
# color reset
function color()
{
	color=( '1' )
	if [ $# -gt 0 ] && [ "${colors[$1]}" ]; then
		color+=( "${colors[$1]}" )
	else
		color=()
	fi
	# set delimiter
	local IFS=';'
	echo -en '\033['"${color[*]}"m
}

# reverse docker's order
# wrap_color <color> <"text">
function wrap_color()
{
	color "$1"
	shift
	echo -ne "$@"
	color reset
	echo
}

function help_msg
{
	echo "$(wrap_color red "Usage:") $0"
	echo -e "\t$(wrap_color yellow "[--help|-h]:") Help message"
	echo
	echo -e "$(wrap_color yellow "Environment Variables:")"
	echo -e "\t$(wrap_color red "IMG") List of docker images to be saved"
	echo -e "\t$(wrap_color red "CPUS") Number of CPUs to be used"
	echo -e "\t\tDEFAULT CPUS=\`grep -c processor /proc/cpuinfo\`"
	echo -e "\t$(wrap_color red "OUTDIR") Output directory"
	echo -e "\t\tDEFAULT OUTPUT=."
	echo -e "\t$(wrap_color red "COMPRESSOR") Compressor command line; take STDIN and output to STDOUT"
	echo -e "\t\tDEFAULT COMPRESSOR=\"pxz -T$CPUS -c9 - \""
	echo -e "\t$(wrap_color red "COMP_EXT") The file extension if the above variable is set"
	echo -e "\t\tDEFAULT COMP_EXT=xz"
	echo -e "\t$(wrap_color red "FILTER") The command to filter the output of \`docker images\`"
	echo -e "\t\tDefault FILTER=\"grep -vi \"^<None>\""
	echo
	echo -e "$(wrap_color yellow Examples:)"
	echo -e "\t1) Save all current docker images except the <None> ones"
	echo -e "\t\t\$ $0"
	echo
	echo -e "\t2) Save one container"
	echo -e "\t\t\$ IMG=debian:jessie $0"
	echo
	echo -e "\t3) Use 4 cpu cores for pxz (default)"
	echo -e "\t\t\$ CPUS=4 $0"
	echo -e "__author__: tuan t. pham"
}

function set_compressor
{
	if [ "$COMPRESSOR" ]; then
		echo "Using user compressor command '$COMPRESSOR'"
		echo "Filename extension = .$COMP_EXT"
		return
	fi

	which pxz >/dev/null
	if [ $? = 0 ]; then
		COMPRESSOR="pxz -T$CPUS -c9 - "
	else
		which xz >/dev/null
		if [ $? = 0 ]; then
			COMPRESSOR="xz -z -c9 "
		fi
	fi

	if [ ! "$COMPRESSOR" ]; then
		echo "Use default compressor gz"
		COMPRESSOR="gz -c"
		COMP_EXT="gz"
	else
		COMP_EXT="xz"
	fi
}

function get_img
{
	if [ ! "$IMG" ]; then
		IMG=`eval $IMG_CMD`
	fi
}

function main
{
	set_compressor
	echo "Compressor Command = '$COMPRESSOR'"
	get_img
	echo -e "Saving image(s):\n$IMG"

	for i in $IMG
	do
		echo -e "\nSaving docker image '$i'"
		OUTFILE=`echo $i | sed -e 's/\//_/g' | sed -e 's/:/_/'`
		CMD="docker save \$i | \$COMPRESSOR > \$OUTDIR/\$OUTFILE.tar.$COMP_EXT"
		echo "Output file = '$OUTDIR/$OUTFILE.tar.$COMP_EXT'"
		# echo $CMD
		eval $CMD
	done
}

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
	help_msg
	exit 0
fi

main
