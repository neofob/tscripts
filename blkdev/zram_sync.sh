#!/bin/bash
# * Load zram
# * Set disksize
# * Mount zram
# * rsync SRC mountpoint
# Assumption: zram module is built and kernel version is 3.15+

# __author__: tuan t. pham <tuan at vt dot edu>

DEBUG=${DEBUG:=0}
CPUS=${CPUS:=$(grep -c processor /proc/cpuinfo)}
MKFS_CMD=${MKFS_CMD:="mkfs.ext4 -m 0 -L"}
ZRAM_LABEL=${ZRAM_LABEL:=FastDisk}
USER=${USER:=$(whoami)}
MAX_DEV=${MAX_DEV:=4}
MEM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
MNT_PREFIX="/tmp"

function log()
{
	if [ "$DEBUG" = 1 ]; then
		echo "$@"
	fi
}

if [ ! "$SIZE" ]; then
	# snippet from init.d/zram
	# Get the available memory in KB
	SIZE=$(((MEM * 50 / 100)))K
	log "SIZE=${SIZE}"
fi

# Load the zram module if it is not loaded alread
function load_mod
{
	# If ZRAM is defined, we assumed that the user knows how things work;
	# we just update the MNT point accordingly
	if [ -b "$ZRAM" ]; then
		[ -n "$MNT" ] || MNT="${MNT_PREFIX}/$(basename ${ZRAM})"
		return
	fi

	# ZRAM is not defined, we will try to load the module
	grep "^zram" /proc/modules >/dev/null
	if [ "$?" = 1 ]; then
		sudo modprobe zram num_devices=$MAX_DEV
		if [ "$?" -eq 1 ]; then
			echo "Fail to load module zram"
			exit 1
		fi
		ZRAM=/dev/zram0
	else
		# We need to check for an available zram device
		ZRAM_DEV=$(ls /dev/zram*)
		for z in $ZRAM_DEV; do
			DEV_NAME=$(basename $z)
			DEV_SIZE=$(cat /sys/block/$DEV_NAME/disksize)
			# find an available zram device
			if [ "$DEV_SIZE" -eq 0 ]; then
				ZRAM=$z
				[ -n "$MNT" ] || MNT="$MNT_PREFIX/$DEV_NAME"
				break
			fi
		done
	fi
}

# Create a filesystem of ext4 from a zram device
# create_zram /dev/zram0 size
# Ex: create_zram /dev/zram1 8G
# size can be in bytes or human-readable format: Number[KMG]?
function create_zram
{
	log "Enter create_zram"
	[ -b "$1" ] || (echo "Device $1 does not exist"; exit 1)
	echo "$2" | grep -o "[0-9]\+[KMG$]\?$" >/dev/null
	if [ "$?" -eq 1 ]; then
		echo "SIZE must be a number of bytes or human-readable format"
		echo "Examples: 123456789, 8000K, 512M, 4G...etc."
		echo "You set SIZE=$SIZE"
		echo -n "Maybe you meant "
		echo "$2" | grep --color=always -o "[0-9]\+[KMG$]\?"
		exit 1
	fi
	DEV_NAME=$(basename $1)
	echo $CPUS | sudo tee /sys/block/$DEV_NAME/max_comp_streams >/dev/null
	echo $2 | sudo tee /sys/block/$DEV_NAME/disksize >/dev/null
	time sudo $MKFS_CMD $ZRAM_LABEL $1
}

# Mount a device on a mount point
# Ex: mount_dev /dev/zram0 /tmp/zram0
function mount_dev
{
	log "Mounting $1 on $2"
	sudo mount $1 $2
	sudo chown $USER:$USER $2
}

# sync_mount src dest
function sync_mount
{
	log "rsync...data from $1 to $2"
	time sudo rsync -av $1/ $2/
}

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
	echo "$(wrap_color red "Usage:") $(basename $0)"
	echo -e "\t$(basename $0) creates a compressed ram disk device, zram, formats it"\
		"in ext4"
	echo -e "\tmounts it, rsync it with your source"
	echo -e "\t$(wrap_color yellow "[--help|-h]:") This help message"
	echo
	echo -e "$(wrap_color yellow "Environment Variables, default value:")"

	echo -e "\t$(wrap_color red "USER")\tusername"
	echo -e "\t\tUSER=\`whoami\`"
	echo -e "\t\t    =$(whoami)"

	echo -e "\t$(wrap_color red "CPUS")\tNumber of CPUs to be used"
	echo -e "\t\tCPUS=\`grep -c proc /proc/cpuinfo\`"
	echo -e "\t\t    =$(grep -c proc /proc/cpuinfo)"

	echo -e "\t$(wrap_color red "ZRAM")\tzram device to be use, e.g. /dev/zram0"
	echo -e "\t\tZRAM=/dev/zram0"

	echo -e "\t$(wrap_color red "SIZE")\tzram device size to be set"
	echo -e "\t\tSIZE=Half of TotalMem ($MEM KB)"

	echo -e "\t$(wrap_color red "MNT")\tMount point"
	echo -e "\t\tMNT=/tmp/zram0"

	echo -e "\t$(wrap_color red "SRC")\tSource directory to be rsync'ed"
	echo -e "\t\tSRC is undefined;"
	echo

	echo -e "\t$(wrap_color red "MKFS_CMD")\tFilesytem command with arguments to be appended at the end: LABEL BLOCKDEV"
	echo -e "\t\tMKFS_CMD=mkfs.ext4 -m 0 -L"
	echo

	echo -e "$(wrap_color yellow Examples:)"
	echo -e "\t1) zram module is loaded, zram0 is used for swap"
	echo -e "\tSo we use zram1 to store data from /media/$(whoami)/usb_drive"
	echo -e "\t\t\$ ZRAM=/dev/zram1 SRC=/media/$(whoami)/usb_drive $0"
	echo

	echo -e "\t2) Specify mount point and others, let the script find the next available zram device"
	echo -e "\t\t\$ CPUS=2 SIZE=4G MNT=/opt/FastDisk SRC=/media/$(whoami)/data $0"
	echo

	echo -e "\t3) Just create zram and format it, use default mount point (/tmp/zramN)"
	echo -e "\t\t\$ SIZE=16G $0"
	echo

	echo -e "\t4) Just create zram and format it, use default mount point (/tmp/zramN) with specied cmd"
	echo -e "\t\t\$ SIZE=16G MKFS_CMD=\"mkfs.ext4 -m 0 -O 64bit -L\" $0"
	echo

	echo -e "__author__: tuan t. pham"
}

function var_dump
{
	VAR_LIST=$(grep -o "^[A-Z_]\+" $0)
	echo $VAR_LIST
	for v in $VAR_LIST; do
		eval "echo $v=\$$v"
	done
	echo "ZRAM=$ZRAM"
	echo "MNT=$MNT"
	echo "SRC=$SRC"
	echo "SIZE=$SIZE"
}

function main
{
	log "Entering main function"
	load_mod
	create_zram $ZRAM $SIZE
	[ -d "$MNT" ] || mkdir -p $MNT
	mount_dev $ZRAM $MNT
	[ -d "$SRC" ] && sync_mount $SRC $MNT
	echo
	echo "Disk Usage of device $(wrap_color red $ZRAM)"
	df -h $ZRAM
}

[ "$DEBUG" = 1 ] && var_dump

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
	help_msg
	exit 0
fi

main
