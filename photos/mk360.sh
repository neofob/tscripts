#!/bin/bash
# Add exif info to image file(s) to be "360" friendly on Facebook
# __author__: tuan t. pham

PTYPE=${PTYPE:="equirectangular"}
CAM_MAKE=${CAM_MAKE:="RICOH"}
CAM_MODEL=${CAM_MODEL:="RICOH THETA S"}

for f in "$@"; do
	echo "Processing $f"
	exiftool -w -ProjectionType="$PTYPE" \
		-Make="$CAM_MAKE" \
		-Model="$CAM_MODEL" \
		$f
done
