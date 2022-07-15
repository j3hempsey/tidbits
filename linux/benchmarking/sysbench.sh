#!/bin/bash
size=10GB
sysbench fileio --file-test-mode=rndrw --file-total-size="$size" prepare
{
	sar -A -o sysbench.dat 1 &> /dev/null
} &
sar_pid=$!
trap 'kill "$sar_pid"' SIGINT SIGTERM EXIT
{
	for mode in seqrd rndrd rndrw seqwr seqrewr rndwr ; do
		sysbench fileio --file-test-mode="$mode" --file-total-size="$size" --time=120 run || exit 1
	done
} |& tee sysbench.out


