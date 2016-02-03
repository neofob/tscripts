#!/bin/bash
# author: tuan t. pham
# tuan at vt dot edu
# This script cd to a list of checked out repositories to do
# a git pull. Use at your own risk.
# The default dryrun will warn you about modified file(s)
# Default parent directory and repositories are set in below
# environment variables.

# Example use with overriden default environment variables.
#	$ DRY_RUN=0 SRC_DIR=. REPOS=`ls -d *` src-pull.sh

# TODO:
#	* Pythonize this in order to process a config type file (use
#		configparser) so that we can customize branch/commit(s)
#		that we can run test--locally for each repository.

# Set environment variables to default variables if they are not set
DRY_RUN=${DRY_RUN:=1}
SRC_DIR=${SRC_DIR:=$HOME/src}
REPOS=${REPOS:="PersonalTools notes linux-stable"}
#BRANCH=${BRANCH:="master"}

function print_help()
{
	echo -e "\e[1;31mUsage:\e[0m src-pull.sh [--help|-h]"
	echo -e "\t-h, --help\tPrint out this help message\n"
	echo -e "\t\e[1;31msrc-pull.sh\e[0m goes through a list of git repositories doing a git pull\n" \
		"\tat the current branch. You can also specify the branch that you want\n" \
		"\tto checkout by setting the env variable BRANCH."
	echo -e "\n\e[1;31mExample:\e[0m"
	echo -e "\t0) Just check all repositories for modified file(s)"
	echo -e "\t\t\$ DRY_RUN=1 SRC_DIR=. REPOS=\`ls -d *\` src-pull.sh"
	echo -e
	echo -e "\t1) Git pull all repositories to the lastest commit"
	echo -e "\t\t\$ DRY_RUN=0 SRC_DIR=. REPOS=\`ls -d *\` src-pull.sh"
}

function exec_gitcheck
{
	RESULT=`git status --porcelain -uno`
	if [ -n "$RESULT" ]; then
		echo -e "\e[1;31mWARNING:\e[0m You have modified file(s) in this repository!"
		echo -e "\e[0;31m"
		git status --porcelain -uno
		echo -e "\e[0m"
	fi
}

function exec_cmd
{
	if [ $DRY_RUN = 0 ]; then
		eval $@
	else
		echo "$@"
	fi
}

function main
{
	pushd . >/dev/null

	if [ $DRY_RUN = 1 ]; then
		echo -e "Dry-run, executing...\n\n"
	else
		echo -e "Do the git pull for REAL!!!\n\n"
	fi

	if [ -z "$BRANCH" ]; then
		CHK_CMD="echo -n"
	else
		CHK_CMD="git checkout $BRANCH"
	fi

	if [ -d $SRC_DIR ]; then
		cd $SRC_DIR
		for dir in $REPOS; do
			(
			cd $dir
			pwd
			exec_gitcheck
			exec_cmd "$CHK_CMD"
			exec_cmd "git pull"
			cd - 1>& /dev/null
			echo -e
			)
		done
	else
		echo "The directory $SRC_DIR does not exist!"
		popd
		exit 1
	fi

	popd >/dev/null
}

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
	print_help
	exit 0
fi

main
