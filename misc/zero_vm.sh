#!/bin/bash
# Author: Tuan T. Pham <tuan at vt dot edu>
# This script umounts the mounted device and calls zerofree on it
# It should be run from a Live CD on the VirtualMachine with virtual disks
# that you want to zero out.
# Usage: # ./zero_vm.sh < mylist.txt
# mylist.txt looks something like this
# /dev/sda1
# /dev/sdb1
# /dev/mapper/bigLVM
# You can also do this if you know that only devices with this pattern
# df | grep "^/dev" | awk '{print $1}' | ./zero_vm.sh
# when you are sure that what you want, set DRY_RUN=0
# df | grep "^/dev" | awk '{print $1}' | DRY_RUN=0 ./zero_vm.sh
DRY_RUN=${DRY_RUN:=1}

function exec_cmd
{
	if [ $DRY_RUN = 0 ]; then
		echo "Executing..."
		eval $@
	else
		echo "Dry-run, executing..."
		echo "$@"
	fi
}
while read device
do
	echo ""
	echo "Zeroing device $device"
	exec_cmd "umount $device"
	exec_cmd "zerofree $device"
done

exit 0
