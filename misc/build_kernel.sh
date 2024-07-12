#!/usr/bin/env bash

# Build new kernel from current kernel config
# tuan t. pham

# Default values
BUILD_OUTPUT=${BUILD_OUTPUT:-/tmp/build}
ARTIFACT=${ARTIFACT:-~/Downloads/kernel}
OLD_CONFIG=${OLD_CONFIG:-"/boot/config-$(uname -r)"}
KERNEL_SRC=${KERNEL_SRC:-"$(pwd)"}
CPUS=${CPUS:-$(nproc)}
DEBUG_INFO=${DEBUG_INFO:-"n"}
FRAME_POINTER=${FRAME_POINTER:-"n"}
UNWINDER_FRAME_POINTER=${UNWINDER_FRAME_POINTER:-"n"}
KGDB=${KGDB:-"n"}
KGDB_SERIAL_CONSOLE=${KGDB_SERIAL_CONSOLE:-"n"}
SYSTEM_TRUSTED_KEYS=${SYSTEM_TRUSTED_KEYS:-""}

# Colors
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
END_COLOR='\033[0m'

# Help message
HELP_MSG="\n${YELLOW}Usage:${END_COLOR} $0
        Build new kernel from the current config file

        ${YELLOW}Required Debian/Ubuntu packages:${END_COLOR}
                * build-essential yacc bison libssl-dev bc

        -d: Dump environment variables
        -h|--help: This help messages

${YELLOW}Default Environment Variables:${END_COLOR}
        ${YELLOW}BUILD_OUTPUT${END_COLOR}=${BUILD_OUTPUT}
                Output directory for object files. One level up is where
                the .deb files are created.

        ${YELLOW}ARTIFACT${END_COLOR}=$ARTIFACT
                Directory where the .deb files are copied to.

        ${YELLOW}OLD_CONFIG${END_COLOR}=$OLD_CONFIG
                Old config file.

        ${YELLOW}KERNEL_SRC${END_COLOR}=$KERNEL_SRC
                Directory of linux kernel source code.

        ${YELLOW}CPUS${END_COLOR}=${CPUS}
                Number of CPU cores to be used.

${YELLOW}Examples:${END_COLOR}
        0) Use the default settings
        $ $0

        1) Set KERNEL_SRC
        $ KERNEL_SRC=/opt/src/linux $0

${GREEN}Author:${END_COLOR} tuan t. pham"

# Function to print help message
print_help() {
        echo -e "$HELP_MSG"
}

# Function to dump environment variables
function dump_vars() {
  declare -a VAR_LIST=("BUILD_OUTPUT" "ARTIFACT" "OLD_CONFIG" "KERNEL_SRC" "CPUS" "KERNEL_VERSION" "OUTPUT_DIR")
  for var in "${VAR_LIST[@]}"; do
    printf "%s=%s\n" "$var" "${!var}"
  done
}

# Function to pause execution
function pause() {
    read -r -p "$*" response
    response=${response#"${response%%[![:space:]]*}"}
    response=${response%"${response##*[![:space:]]}"}
}

# Function to set custom environment
function set_custom_env() {
  config_opts=(
    "DEBUG_INFO=n"
    "SYSTEM_TRUSTED_KEYS=''"
    "KGDB=n"
    "KGDB_SERIAL_CONSOLE=n"
    "FRAME_POINTER=n"
    "UNWINDER_FRAME_POINTER=n"
  )

  for opt in "${config_opts[@]}"; do
    key=$(cut -d '=' -f 1 <<< "$opt")
    value=${opt#*=}

    if [[ $value == "n" ]]; then
      scripts/config --file "$BUILD_OUTPUT/.config" --disable "$key"
    elif [[ $value == "y" ]]; then
      scripts/config --file "$BUILD_OUTPUT/.config" --enable "$key"
    elif [[ -n $value ]]; then
      scripts/config --file "$BUILD_OUTPUT/.config" --set-str "$key" "$value"
    fi
  done
}

# Function to set up environment
function setup_env() {
  echo -e "${YELLOW}Setting the environment${END_COLOR}"
  [ -d "${BUILD_OUTPUT}" ] || mkdir -p ${BUILD_OUTPUT}
  [ -d "$ARTIFACT" ] || mkdir -p $ARTIFACT
  export KBUILD_OUTPUT=${BUILD_OUTPUT}
  cp ${OLD_CONFIG} ${BUILD_OUTPUT}/.config
  cd ${KERNEL_SRC} || exit 1
  echo -e "${YELLOW}Creating the new config file based on ${OLD_CONFIG}${END_COLOR}"
  make -s olddefconfig
  set_custom_env
  KERNEL_VERSION=$(make -s kernelversion)
  OUTPUT_DIR=${ARTIFACT}/${KERNEL_VERSION}
  mkdir -p ${OUTPUT_DIR}
}


# Function to build kernel
build_kernel() {
        echo -e "${YELLOW}Building kernel version ${KERNEL_VERSION}...${END_COLOR}"

        # Build the new kernel
        make -s -j"${CPUS}"

        # Build binary debian packages
        make -s -j"${CPUS}" bindeb-pkg

        echo -e "${GREEN}Kernel build complete!${END_COLOR}"
}

# Function to copy artifacts
copy_artifacts() {
        echo -e "${YELLOW}Copying artifacts...${END_COLOR}"

        # Copy .deb and .changes files to OUTPUT_DIR
        cp "${BUILD_OUTPUT}/../linux-*${KERNEL_VERSION}*.changes" "${OUTPUT_DIR}"
        cp "${BUILD_OUTPUT}/../linux-*${KERNEL_VERSION}*.buildinfo" "${OUTPUT_DIR}"
        cp "${BUILD_OUTPUT}/../linux-{headers,image}-${KERNEL_VERSION}*.deb" "${OUTPUT_DIR}"
        cp "${BUILD_OUTPUT}/../linux-libc-dev_${KERNEL_VERSION}*.deb" "${OUTPUT_DIR}"
        cp "${BUILD_OUTPUT}/.config" "${OUTPUT_DIR}/config-${KERNEL_VERSION}"

        echo -e "${GREEN}Artifacts copied!${END_COLOR}"
}

# Main function
main() {
        if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
                print_help
                exit 0
        fi

        if [ "$1" = "-d" ]; then
                dump_vars
                exit 0
        fi

        # Set up environment
        setup_env || {
                echo -e "${RED}Error: Failed to set up environment${END_COLOR}"
                exit 1
        }

        # Build kernel
        build_kernel || {
                echo -e "${RED}Error: Failed to build kernel${END_COLOR}"
                exit 1
        }

        # Copy artifacts
        copy_artifacts || {
                echo -e "${RED}Error: Failed to copy artifacts${END_COLOR}"
                exit 1
        }

        echo -e "${GREEN}Kernel build and copy complete!${END_COLOR}"
}

main "$@"
