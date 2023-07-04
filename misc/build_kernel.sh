#!/usr/bin/env bash
# Build new kernel from current kernel config
# tuan t. pham

BUILD_OUTPUT=${BUILD_OUTPUT:=/tmp/build}
ARTIFACT=${ARTIFACT:=~/Downloads/kernel}
OLD_CONFIG=${OLD_CONFIG:=/boot/config-`uname -r`}
KERNEL_SRC=${KERNEL_SRC:=`pwd`}
CPUS=${CPUS:=$(grep -c processor /proc/cpuinfo)}
KERNEL_VERSION=""
OUTPUT_DIR=""
SYSTEM_TRUSTED_KEYS=${SYSTEM_TRUSTED_KEYS:=""}

# Set this to "y" if you need debug info
DEBUG_INFO=${DEBUG_INFO:="n"}

# Some custom settings
FRAME_POINTER=${FRAME_POINTER:="n"}
UNWINDER_FRAME_POINTER=${UNWINDER_FRAME_POINTER:="n"}
KGDB=${KGDB:="n"}
KGDB_SERIAL_CONSOLE=${KGDB_SERIAL_CONSOLE:="n"}

red="\e[1;31m"
yellow="\e[1;33m"
end="\e[0m"

help_msg="${red}Usage:${end} $0
	Build new kernel from the current config file

	Required Debian/Ubuntu packages:
		* build-essential yacc bison libssl-dev bc

	-d: Dump environment variables

	-h|--help: This help messages

${red}Default Environment Variables:${end}
	${yellow}BUILD_OUTPUT${end}=${BUILD_OUTPUT}
		Output directory for object files. One level up is where
		the .deb files are created.

	${yellow}ARTIFACT${end}=$ARTIFACT
		Directory where the .deb files are copied to.

	${yellow}OLD_CONFIG${end}=$OLD_CONFIG
		Old config file.

	${yellow}KERNEL_SRC${end}=$KERNEL_SRC
		Directory of linux kernel source code.

	${yellow}CPUS${end}=${CPUS}
		Number of CPU cores to be used.

${red}Examples:${end}
	0) Use the default settings
	$ $0

	1) Set KERNEL_SRC
	$ KERNEL_SRC=/opt/src/linux $0

__author__: tuan t. pham"

function print_help()
{
	exec echo -e "$help_msg"
}

function dump_vars()
{
	VAR_LIST="BUILD_OUTPUT ARTIFACT OLD_CONFIG KERNEL_SRC CPUS KERNEL_VERSION OUTPUT_DIR"
	for v in $VAR_LIST; do
		eval echo "$v=\$$v"
	done
}

function pause()
{
	 read -p "$*"
}

function set_custom_env()
{
	if [ $DEBUG_INFO = "n" ]; then
		scripts/config --file $BUILD_OUTPUT/.config --disable DEBUG_INFO
	else
		scripts/config --file $BUILD_OUTPUT/.config --enable DEBUG_INFO
	fi

	scripts/config --file $BUILD_OUTPUT/.config --set-str SYSTEM_TRUSTED_KEYS "$SYSTEM_TRUSTED_KEYS"

	if [ $KGDB = "n" ]; then
		scripts/config --file $BUILD_OUTPUT/.config --disable KGDB
	else
		scripts/config --file $BUILD_OUTPUT/.config --enable KGDB
	fi

	if [ $KGDB_SERIAL_CONSOLE = "n" ]; then
		scripts/config --file $BUILD_OUTPUT/.config --disable KGDB_SERIAL_CONSOLE
	else
		scripts/config --file $BUILD_OUTPUT/.config --enable KGDB_SERIAL_CONSOLE
	fi

	if [ $FRAME_POINTER = "n" ]; then
		scripts/config --file $BUILD_OUTPUT/.config --disable FRAME_POINTER
	else
		scripts/config --file $BUILD_OUTPUT/.config --enable FRAME_POINTER
	fi

	if [ $UNWINDER_FRAME_POINTER = "n" ]; then
		scripts/config --file $BUILD_OUTPUT/.config --disable UNWINDER_FRAME_POINTER
	else
		scripts/config --file $BUILD_OUTPUT/.config --enable UNWINDER_FRAME_POINTER
	fi
}

function setup_env()
{
	echo "Setting the environment"
	[ -d "${BUILD_OUTPUT}" ] || mkdir -p ${BUILD_OUTPUT}
	[ -d "$ARTIFACT" ] || mkdir -p $ARTIFACT
	export KBUILD_OUTPUT=${BUILD_OUTPUT}
	cp $OLD_CONFIG ${BUILD_OUTPUT}/.config
	cd $KERNEL_SRC || exit 1
	echo "Creating the new config file based on $OLD_CONFIG"
	make -s olddefconfig
	set_custom_env
	KERNEL_VERSION=$(make -s kernelversion)
	OUTPUT_DIR=$ARTIFACT/$KERNEL_VERSION
	mkdir -p ${OUTPUT_DIR}
}

function build_kernel()
{
	echo "Environment variables"
	dump_vars
	echo "Building the new kernel version $KERNEL_VERSION"
	make -s -j${CPUS}
	echo "Building binary debian packages"
	make -s -j${CPUS} bindeb-pkg

	echo "Copying .deb and .changes files to ${OUTPUT_DIR}"
	cp ${BUILD_OUTPUT}/../linux-${KERNEL_VERSION}*.changes ${OUTPUT_DIR}
	cp ${BUILD_OUTPUT}/../linux-{headers,image}-${KERNEL_VERSION}*.deb ${OUTPUT_DIR}
	cp ${BUILD_OUTPUT}/../linux-libc-dev_${KERNEL_VERSION}*.deb ${OUTPUT_DIR}
#	cp ${BUILD_OUTPUT}/../linux-firmware-image-${KERNEL_VERSION}*.deb ${OUTPUT_DIR}
	echo "DONE!!!"
}

function main()
{
	if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		print_help
		exit 1
	fi

	if [ "$1" = "-d" ]; then
		dump_vars
		exit 0
	fi

	pushd . >/dev/null
	setup_env
	build_kernel
    sync
	popd >/dev/null
}

main "$@"
