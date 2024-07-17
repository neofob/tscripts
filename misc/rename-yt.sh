#!/usr/bin/env bash
SRC_DIR=${SRC_DIR:=.}

pushd $SRC_DIR >/dev/null
OFFSET=${OFFSET:-0}
POSTFIX=${POSTFIX:-"-Summary.md"}
PATTERN=${PATTERN:-"*"}
DRY_RUN=${DRY_RUN:-1}
for f in $(ls $PATTERN); do
	tmp_file=$f
	tmp_file="${tmp_file::-$OFFSET}"
	#tmp_file="${tmp_file::-23}"
	#tmp_file="${tmp_file::-16}" #*.mp4
	tmp_file=$(echo $tmp_file | \
				sed -e "s/-//g" | \
				sed -e "s/__/_/g" | \
				sed -e "s/%//g" | \
				sed -e "s/+//g" | \
				sed -e "s/__/_/g" | \
				sed -e "s/=//g" | \
				sed -e "s/__/_/g" \
			)
	out_file="$tmp_file""$POSTFIX"
	#echo $out_file
	#[[ $DRY_RUN -eq 0 ]] && echo "mv $f $out_file"
	if [[ $DRY_RUN -eq 0 ]]; then
		mv $f $out_file
	else
		echo "DRY_RUN: mv $f $out_file"
	fi
done

popd > /dev/null
