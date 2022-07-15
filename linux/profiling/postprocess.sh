#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

# shellcheck disable=SC2034
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
	cat <<-EOF
	Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] <sar-data-filename>

	This script processes a sar data file and outputs corresponding charts for captured data.

	Available options:

	    --auto-range Let gnuplot decide the best ranges to use for the y-axis of plots.
	-o, --out-dir    Processing output directory (will be created).

	Available quantization outputs:

	-a, --all        All available analysis.
	-c, --cpu        CPU analysis and plotting.
	-m, --mem        Memory analysis and plotting.
	-i, --io         I/O analysis and plotting.

	Misc:
	-h, --help       Print this help and exit.
	-v, --verbose    Print script debug info,
	EOF
	exit
}

cleanup() {
	trap - SIGINT SIGTERM ERR EXIT
	# script cleanup here
}

setup_colors() {
	if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
		NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
	else
		# shellcheck disable=SC2034
		NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
	fi
}

msg() {
	echo >&2 -e "${1-}"
}

die() {
	local msg=$1
	local code=${2-1} # default exit status 1
	msg "${RED}$msg${NOFORMAT}"
	exit "$code"
}

parse_params() {
	filename=''
	autorange=0
	# analysis flags
	cpu=0
	mem=0
	io=0

	while :; do
		case "${1-}" in
			# Options
			--auto-range) autorange=1 ;;
			-o | --out-dir)
				outdir="${2-}"
				shift
				;;
			# Metrics
			-a | --all)
				cpu=1
				mem=1
				io=1
			;;
			-c | --cpu) cpu=1 ;;
			-m | --mem) mem=1 ;;
			-i | --io )  io=1 ;;
			# Misc
			-h | --help) usage ;;
			-v | --verbose) set -x ;;
			--no-color) NO_COLOR=1 ;;
			-?*) die "Unknown option: $1" ;;
			*) break ;;
		esac
		shift
	done

	args=("$@")

	# check required params and arguments
	[[ ${#args[@]} -eq 0 ]] && die "Missing sar data file."
	filename=${args[0]}
	[[ -z "${filename-}" ]] && die "Missing required parameter: --file"
	[[ ! -f "$filename" ]] && die "$filename does not exist!"

	return 0
}

sadf-post() {
	# It seems that in some cases sar can record a date in the past (epoch 0), use awk to filter our
	# data to ensure the time is always increasing.
	sadf -dh "$@" |
		awk -F\; 'BEGIN { date=0 };
					/^#/ { print $0 };
					!/^#/{ if ($3 > date) { print $0; date=$3 } }'
}

parse_params "$@"
setup_colors

if ! gawk --version &>/dev/null; then
	die "gawk must be installed!"
fi

# script logic here
outdir="${outdir:-$(date +"%Y%m%d_%H%M").proc}"
msg "${BLUE}Performing analysis of sar data from:${NOFORMAT} $filename"
msg "${BLUE}Output directory:${NOFORMAT} $outdir"
if (( cpu )); then
	msg "${BLUE}Plotting CPU data${NOFORMAT}"
	plot_out_dir="$outdir/cpu"
	export_name="$plot_out_dir/$filename".cpu.dat
	mkdir -p "$plot_out_dir"

	sadf-post -P ALL "$filename" > "$export_name"
	gnuplot -e "datafile='$export_name'" -e "outdir='$plot_out_dir'" -e "autorange='$autorange'" \
		gnuplots/plotstats.cpuall.plot
	msg "${GREEN}Done!${NOFORMAT}"
fi

if (( mem )); then
	msg "${BLUE}Plotting memory data${NOFORMAT}"
	plot_out_dir="$outdir/mem"
	export_name="$plot_out_dir/$filename".mem.dat
	mkdir -p "$plot_out_dir"

	sadf-post "$filename" -- -r > "$export_name"
	gnuplot -e "datafile='$export_name'" -e "outdir='$plot_out_dir'" -e "autorange='$autorange'" \
		gnuplots/plotstats.mem.plot
	msg "${GREEN}Done!${NOFORMAT}"
fi

if (( io )); then
	msg "${BLUE}Plotting I/O data${NOFORMAT}"
	plot_out_dir="$outdir/io"
	export_name="$plot_out_dir/$filename".io.dat
	mkdir -p "$plot_out_dir"

	sadf-post "$filename" -- -b > "$export_name"
	gnuplot -e "datafile='$export_name'" -e "outdir='$plot_out_dir'" -e "autorange='$autorange'" \
		gnuplots/plotstats.io.plot
	msg "${GREEN}Done!${NOFORMAT}"
fi
