#!/usr/bin/env bash
SRC_DIR=${SRC_DIR:=.}

# This is terrible!
# TODO: Nerd up and figure out the file extension pattern matching
# FILE_PATTERN
# .mp4
# .mkv
# .webm

pushd $SRC_DIR >/dev/null

IFS=$'\n'$'\r'
# .mp4 pass
LIST=`ls -1 --quoting-style=shell *.mp4 2>/dev/null`
if [ $? -eq 0 ]; then
	for f in $LIST; do
		outfile=$(echo ${f} | sed -e 's/,//g' \
			| tr '() ' '___' \
			| sed -e 's/_-_/-/g' \
			| sed -e 's/\._/_/' \
			| sed -e 's/___/_/g' \
			| sed -e 's/-.\{11\}\.mp4/\.mp4/')
		if [ "$f" != "$outfile" ]; then
			#echo "${f} ${outfile}"
			echo "${f} ${outfile}" | xargs mv
		fi

	done
fi

# .mkv pass
LIST=`ls -1 --quoting-style=shell *.mkv 2>/dev/null`
if [ $? -eq 0 ]; then
	for f in $LIST; do
		outfile=$(echo ${f} | sed -e 's/,//g' \
			| tr '() ' '___' \
			| sed -e 's/_-_/-/g' \
			| sed -e 's/\._/_/' \
			| sed -e 's/___/_/g' \
			| sed -e 's/-.\{11\}\.mkv/\.mkv/')
		if [ "$f" != "$outfile" ]; then
			echo "${f} ${outfile}" | xargs mv
		fi
	done
fi

# .webm pass
LIST=`ls -1 --quoting-style=shell *.webm 2>/dev/null`
if [ $? -eq 0 ]; then
	for f in $LIST; do
		outfile=$(echo ${f} | sed -e 's/,//g' \
			| tr '() ' '___' \
			| sed -e 's/_-_/-/g' \
			| sed -e 's/\._/_/' \
			| sed -e 's/___/_/g' \
			| sed -e 's/-.\{11\}\.webm/\.webm/')
		if [ "$f" != "$outfile" ]; then
			echo "${f} ${outfile}" | xargs mv
		fi
	done
fi

popd > /dev/null
