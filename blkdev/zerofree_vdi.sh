#!/bin/bash
# Mount virtual disk image, vdi and what not, as an nbd
# then zerofree it, assuming that the filesystem is ext[3-4]
# Just run this script as root so it doesnt have to sudo
# __author__: tuan t. pham <tuan at vt dot edu>

NBD_DEV=${NBD_DEV:="/dev/nbd0"}
VPART=${VPART:=1}
ZEROFREE=${ZEROFREE:=zerofree}
NBD_CMD_C="qemu-nbd -c"
NBD_CMD_D="qemu-nbd -d"

# It is useful with non-spinning disks, SSD...
# Multithread  version @ https://github.com/neofob/zerofree
# Unset this if you use a zerofree supports multithread and the virtual image
# file resides on a SSD or non-spinning disk
# ZEROFREE_OPTS="-t 4"

help_msg="\e[1;31mUsage:\e[0m $0 <VirtualDiskImage>
	zerofree a virtual disk using nbd, Network Block Device, loopback mounting
	Run this script with sudo or as \e[1;31mroot\e[0m

\e[1;31mEnvironment variables:\e[0m
	NBD_DEV Network Block Device to be used
		e.g. /dev/nbd0, /dev/nbd1
		DEFAULT NBD_DEV=/dev/nbd0

\e[1;31mExamples:\e[0m
	0) Use the default /dev/nbd0 for virtual image disk
	# $0 Jessie.vdi

	1) Use nbd2 as a nbd loopback device and zerofree the 2nd partion
	# NBD_DEV=/dev/nbd2 VPART=2 $0 Jessie.vdi

\e[1;33mRequirement package(s) (debian/ubuntu):\e[0m
	# apt-get install -yq qemu-utils zerofree
	# modprobe nbd max_part=16

__author__: tuan t. pham"

function print_help()
{
	exec echo -e "$help_msg"
}

# e.g.: mount_nbd /dev/nbd0 jessie.vdi
# Now we have /dev/nbd0 block device as well ass /dev/nbd0p* partition(s)
function mount_nbd()
{
	echo "Entering mount_nbd $1 $2"
	eval "$NBD_CMD_C $1 $2"
}

# e.g.: umount_nbd /dev/nbd0
function umount_nbd()
{
	echo "Entering umount_nbd $1"
	eval "$NBD_CMD_D $1"
}

# e.g.: zerofree_func /dev/nbd0p1
function zerofree_func()
{
	echo "Entering zerofree_func $1"
	time $ZEROFREE $ZEROFREE_OPTS $1
}

function main()
{
	echo "Entering main function"
	mount_nbd "$NBD_DEV $1"
	zerofree_func "$NBD_DEV""p$VPART"
	umount_nbd "$NBD_DEV"
}

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
	print_help
	exit 0
elif [ ! -f "$1" ]; then
	echo "$1 does not exist"
	echo
	help_msg
	exit 1
fi

main "$@"
