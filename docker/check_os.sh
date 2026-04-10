#!/usr/bin/env bash

# check /etc/os-release
# check_os.sh image_name
echo "cat /etc/os-release" | docker run --rm -i --user root --entrypoint /bin/sh $1
