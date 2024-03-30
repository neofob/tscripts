#!/usr/bin/env bash

# Change permission of directories and files to 0755 and 0644, respectively.
# Author: Tuan T. Pham

# chmod.sh [directory..]

for d in "$@"; do
  find "$d" -type d -exec chmod 0755 {} +
  find "$d" -type f -exec chmod 0644 {} +
done
