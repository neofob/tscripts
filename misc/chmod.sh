#!/bin/bash

# This simple script recursively traverses all subdirs.
# It chmod 644 files and 755 directories. This script
# assume that it is in $PATH; so cp it to your ~/bin or
# something.
# Author: Tuan T. Pham

# It is in DRY_RUN mode by default.
# Usage:
# chmod.sh [directory..]
# To run for real
# DRY_RUN=0 chmod.sh director

DRY_RUN=${DRY_RUN:=1}

function exec_cmd
{
        if [ $DRY_RUN = 0 ]; then
                $@
        else
                echo "Dry-run, executing..."
                echo "$@"
        fi
}

for file in $@; do
	if [ -d "$file" ]; then
		(
		exec_cmd "chmod 755 $file"
		exec_cmd "cd $file"
		exec_cmd "$0 *"
		)
	else
		exec_cmd "chmod 644 $file"
	fi
done
