#!/bin/bash
#GB
size=40
file_prefix=dd-bench

if ! type sar &>/dev/null; then
	echo "sar (sysstat package) needs to be installed"
	exit 1
fi

(
	sar -A -o "$file_prefix.dd.dat" 1 &> /dev/null
) &
sar_pid=$!

cleanup() {
	kill "$sar_pid"
	rm -f tmp.file
}
trap 'cleanup' SIGINT SIGTERM EXIT
{
	dd if=/dev/urandom of=tmp.file conv=fdatasync bs=4M count=$(( size * 1024 / 4 ))
} |& tee "$file_prefix.dd.out"


