#!/usr/bin/env bash
# Quik script to benchmark pxz with many-core
# Edit CORE_LOOP if you have more cores to test
# __author__: tuan t. pham

DATE_FMT=`date +%y%m%d`
SCRIPT_OUTPUT=${SCRIPT_OUTPUT:=pxz_benchmark-$DATE_FMT.log}
BS=${BS:=1M}
BCOUNT=${BCOUNT:=16000}
CORE_LOOP=${CORE_LOOP:="1 2 4 8 16 32"}

echo "Output file is ${SCRIPT_OUTPUT}"
echo "Testing on `date`" | tee -a ${SCRIPT_OUTPUT}
echo "Blocksize = ${BS}" | tee -a ${SCRIPT_OUTPUT}
echo "BlockCount = ${BCOUNT}" | tee -a ${SCRIPT_OUTPUT}
echo "Core Loop = ${CORE_LOOP}" | tee -a ${SCRIPT_OUTPUT}

for c in ${CORE_LOOP}; do
	echo "Testing $c core" | tee -a ${SCRIPT_OUTPUT}
	time dd if=/dev/zero bs=${BS} count=${BCOUNT} | pv | xz -T${c} -c9 - >/dev/null | tee -a ${SCRIPT_OUTPUT}
done
