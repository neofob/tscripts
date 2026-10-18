#!/usr/bin/env bash

# Enable strict mode:
# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error.
# -o pipefail: Return value of a pipeline is the status of the last command to exit with a non-zero status.
set -euo pipefail

# Build new kernel from current kernel config
# tuan t. pham

# Default values
BUILD_OUTPUT=${BUILD_OUTPUT:-/tmp/build}
ARTIFACT=${ARTIFACT:-"$HOME/Downloads/kernel"}
OLD_CONFIG=${OLD_CONFIG:-"/boot/config-$(uname -r)"}
KERNEL_SRC=${KERNEL_SRC:-"$(pwd)"}
CPUS=${CPUS:-$(nproc)}
DEBUG_INFO=${DEBUG_INFO:-"n"}
FRAME_POINTER=${FRAME_POINTER:-"n"}
UNWINDER_FRAME_POINTER=${UNWINDER_FRAME_POINTER:-"n"}
KGDB=${KGDB:-"n"}
KGDB_SERIAL_CONSOLE=${KGDB_SERIAL_CONSOLE:-"n"}
SYSTEM_TRUSTED_KEYS=${SYSTEM_TRUSTED_KEYS:-""}

# Globals populated during execution
KERNEL_VERSION=""
OUTPUT_DIR=""

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
    printf '%b\n' "${HELP_MSG}"
}

# Function to dump environment variables
dump_vars() {
    local VAR_LIST=("BUILD_OUTPUT" "ARTIFACT" "OLD_CONFIG" "KERNEL_SRC" "CPUS" "KERNEL_VERSION" "OUTPUT_DIR")
    for var in "${VAR_LIST[@]}"; do
        # Use indirect expansion safely
        printf "%s=%s\n" "$var" "${!var:-}"
    done
}

# Function to set custom environment
set_custom_env() {
    local config_opts=(
        "DEBUG_INFO_COMPRESSED=n"
        "DEBUG_INFO_DWARF5=n"
        "DEBUG_INFO=$DEBUG_INFO"
        "FRAME_POINTER=$FRAME_POINTER"
        "GDB_SCRIPTS=n"
        "KGDB=$KGDB"
        "KGDB_SERIAL_CONSOLE=$KGDB_SERIAL_CONSOLE"
        "SYSTEM_TRUSTED_KEYS=$SYSTEM_TRUSTED_KEYS"
        "UNWINDER_FRAME_POINTER=$UNWINDER_FRAME_POINTER"
    )

    # scripts/config accepts multiple commands in a single invocation, which
    # avoids a full-file sed pass per option.
    local key value args=()
    for opt in "${config_opts[@]}"; do
        key=${opt%%=*}
        value=${opt#*=}
        printf '%s=%s\n' "$key" "$value"

        if [[ "$value" == "n" ]]; then
            args+=(--disable "$key")
        elif [[ "$value" == "y" ]]; then
            args+=(--enable "$key")
        elif [[ -n "$value" ]]; then
            args+=(--set-str "$key" "$value")
        fi
    done

    if [[ ${#args[@]} -gt 0 ]]; then
        scripts/config --file "${BUILD_OUTPUT}/.config" "${args[@]}"
    fi
}

# Function to set up environment
setup_env() {
    printf '%b\n' "${YELLOW}Setting the environment${END_COLOR}"

    if [[ ! -f "${OLD_CONFIG}" ]]; then
        printf '%b\n' "${RED}Config file not found: ${OLD_CONFIG}${END_COLOR}" >&2
        exit 2
    fi
    if [[ ! -f "${KERNEL_SRC}/Makefile" || ! -x "${KERNEL_SRC}/scripts/config" ]]; then
        printf '%b\n' "${RED}Not a kernel source tree: ${KERNEL_SRC}${END_COLOR}" >&2
        exit 2
    fi

    # Resolve to absolute paths before changing directory
    OLD_CONFIG="$(realpath -m "${OLD_CONFIG}")"
    BUILD_OUTPUT="$(realpath -m "${BUILD_OUTPUT}")"
    ARTIFACT="$(realpath -m "${ARTIFACT}")"

    mkdir -p "${BUILD_OUTPUT}"
    mkdir -p "${ARTIFACT}"

    export KBUILD_OUTPUT="${BUILD_OUTPUT}"

    cd "${KERNEL_SRC}" || {
        printf '%b\n' "${RED}Failed to cd into ${KERNEL_SRC}${END_COLOR}" >&2
        exit 2
    }

    printf '%b\n' "${YELLOW}Creating the new config file based on ${OLD_CONFIG}${END_COLOR}"
    cp "${OLD_CONFIG}" "${BUILD_OUTPUT}/.config"

    # Apply custom options first, then resolve so the built config and the
    # saved artifact are always in sync.
    set_custom_env
    make -s olddefconfig

    KERNEL_VERSION=$(make -s kernelversion)
    OUTPUT_DIR="${ARTIFACT}/${KERNEL_VERSION}"
    mkdir -p "${OUTPUT_DIR}"
}

# Function to build kernel
build_kernel() {
    printf '%b\n' "${YELLOW}Building kernel version ${KERNEL_VERSION}...${END_COLOR}"

    # Build the kernel and binary debian packages in a single pass.
    # .deb/.changes/.buildinfo files are written to the parent of
    # ${BUILD_OUTPUT}.
    make -s -j"${CPUS}" bindeb-pkg

    printf '%b\n' "${GREEN}Kernel build complete!${END_COLOR}"
}

# Function to copy artifacts
copy_artifacts() {
    printf '%b\n' "${YELLOW}Copying artifacts...${END_COLOR}"

    # bindeb-pkg places its outputs in the parent of ${BUILD_OUTPUT}
    local src_dir
    src_dir="$(dirname "${BUILD_OUTPUT}")"

    local patterns=(
        "linux-*${KERNEL_VERSION}*.changes"
        "linux-*${KERNEL_VERSION}*.buildinfo"
        "linux-headers-${KERNEL_VERSION}*.deb"
        "linux-image-${KERNEL_VERSION}*.deb"
        "linux-libc-dev_${KERNEL_VERSION}*.deb"
    )

    local pattern files=() missing=()
    for pattern in "${patterns[@]}"; do
        # compgen -G matches the glob and exits 1 (harmless inside process
        # substitution) when nothing matches.
        mapfile -t files < <(compgen -G "${src_dir}/${pattern}")

        if (( ${#files[@]} == 0 )); then
            missing+=("${src_dir}/${pattern}")
        else
            cp -- "${files[@]}" "${OUTPUT_DIR}/"
        fi
    done

    if (( ${#missing[@]} > 0 )); then
        printf '%b\n' "${RED}Expected artifacts not found:${END_COLOR}" >&2
        local entry
        for entry in "${missing[@]}"; do
            printf '  %s\n' "${entry}" >&2
        done
        exit 3
    fi

    cp -- "${BUILD_OUTPUT}/.config" "${OUTPUT_DIR}/config-${KERNEL_VERSION}"

    printf '%b\n' "${GREEN}Artifacts copied to ${OUTPUT_DIR}!${END_COLOR}"
}

# Main function
main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                print_help
                exit 0
                ;;
            -d|--dump)
                dump_vars
                exit 0
                ;;
            *)
                printf '%b\n' "${RED}Unknown option: $1${END_COLOR}" >&2
                print_help
                exit 1
                ;;
        esac
    done

    # Execute workflow
    setup_env
    build_kernel
    copy_artifacts

    printf '%b\n' "${GREEN}Kernel build and copy complete!${END_COLOR}"
}

main "$@"
