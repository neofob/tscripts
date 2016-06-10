#!/bin/bash
# Set all cpus to a governor: performance, ondemand, powersave..etc.
# tuan t. tpham

help_msg="\e[1;31mUsage:\e[0m $0 <governor>

	governor: any available governor that your kernel provides.
	Depending your kernel, one or more than one of these governors
	might be available:
		ondemand, performance, conservative, powersave, userspace

	For a list of available governors,
		$ grep CONFIG_CPU_FREQ_GOV /boot/config-`uname -r`

\e[1;31mExample:\e[0m
	0) Set all cpus to 'powersave'
	$ $0 powersave

	1) Set all cpus to 'performance'
	$ $0 performance

__author__: tuan t. pham"

function print_help()
{
	exec echo -e "$help_msg"
}

CPUS=${CPUS:=`grep processor /proc/cpuinfo | awk '{print $3}'`}

function main()
{
	if [ -z $1 ]; then
		print_help
		exit 1
	fi

	for cpuid in $CPUS; do
		cpufreq-set -c $cpuid -g $1
	done
}

main $@
