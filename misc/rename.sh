#!/usr/bin/env bash
SRC_DIR=${SRC_DIR:=.}

# This is terrible!
# TODO: Nerd up and figure out the file extension pattern matching
# FILE_PATTERN
# .mp4
# .mkv
# .webm

pushd $SRC_DIR >/dev/null
IFS=","

# .mp4 pass
LIST=`ls -m *.mp4 2>/dev/null`
if [ $? -eq 0 ]; then
	for f in $LIST; do
		infile=`echo -n ${f} | sed -e 's/ /\\\ /g'`
		outfile=`echo -n ${f} | sed -e 's/ /_/g' | sed -e 's/-.\{11\}\.mp4$/.mp4/'`
		if [ "$infile" != "$outfile" ]; then
			echo -n "${infile} ${outfile}" | xargs -n 2 mv
		fi

	done
fi

# .mkv pass
LIST=`ls -m *.mkv 2>/dev/null`
if [ $? -eq 0 ]; then
	for f in $LIST; do
		infile=`echo -n ${f} | sed -e 's/ /\\\ /g'`
		outfile=`echo -n ${f} | sed -e 's/ /_/g' | sed -e 's/-.\{11\}\.mkv$/.mkv/'`
		if [ "$infile" != "$outfile" ]; then
			echo -n "${infile} ${outfile}" | xargs -n 2 mv
		fi
	done
fi

# .webm pass
LIST=`ls -m *.webm 2>/dev/null`
if [ $? -eq 0 ]; then
	for f in $LIST; do
		infile=`echo -n ${f} | sed -e 's/ /\\\ /g'`
		outfile=`echo -n ${f} | sed -e 's/ /_/g' | sed -e 's/-.\{11\}\.webm$/.webm/'`
		if [ "$infile" != "$outfile" ]; then
			echo -n "${infile} ${outfile}" | xargs -n 2 mv
		fi
	done
fi

popd > /dev/null
