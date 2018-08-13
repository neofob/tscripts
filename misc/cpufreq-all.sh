#!/bin/bash
# Set all cpus to a governor: performance, ondemand, powersave..etc.
# tuan t. tpham
red="\e[1;31m"
yellow="\e[1;33m"
end="\e[0m"

help_msg="${red}Usage:${end} $0 <governor>

	governor: any available governor that your kernel provides.
	Depending your kernel, one or more than one of these governors
	might be available:
		ondemand, performance, conservative, powersave, userspace

	For a list of available governors,
		$ cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors

${red}Example:${end}
	0) Set all cpus to 'powersave'
	$ $0 powersave

	1) Set all cpus to 'performance'
	$ $0 performance

__author__: tuan t. pham"

function print_help()
{
	exec echo -e "$help_msg"
}

CPUS=${CPUS:=$(grep processor /proc/cpuinfo | awk '{print $3}')}

function main()
{
	if [ -z $1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		print_help
		exit 1
	fi

	for cpuid in $CPUS; do
		cpufreq-set -c $cpuid -g $1
	done
}

main $@
