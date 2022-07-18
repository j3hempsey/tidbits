#!/bin/bash
size=40GB
file_prefix=test-sysbench

if ! type sar &>/dev/null; then
	echo "sar (sysstat package) needs to be installed"
	exit 1
fi

if ! type sysbench &>/dev/null; then
	echo "sysbench needs to be installed"
	exit 1
fi

sysbench fileio --file-test-mode=rndrw --file-total-size="$size" prepare
(
	sar -A -o "$file_prefix.sysbench.dat" 1 &> /dev/null
) &
sar_pid=$!
trap 'kill "$sar_pid"' SIGINT SIGTERM EXIT
{
	for mode in seqrd rndrd rndrw seqwr seqrewr rndwr ; do
		sysbench fileio --file-test-mode="$mode" --file-total-size="$size" --time=120 run || exit 1
	done
} |& tee "$file_prefix.sysbench.out"


