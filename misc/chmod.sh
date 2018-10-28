#!/usr/bin/env bash

# Change permission of directories and files to 0755 and
# 0644, respectively.
# Author: Tuan T. Pham

# chmod.sh [directory..]

for d in $@; do
	# Directory pass
	find $d -type d -print | xargs chmod 755
	# File pass
	find $d -type f -print | xargs chmod 644
done
