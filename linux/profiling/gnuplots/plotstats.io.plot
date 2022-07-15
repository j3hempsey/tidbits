if (!exists("datafile")) datafile='tmp.io.dat'
if (!exists("outdir")) outdir='io'
if (!exists("autorange")) autorange=0

set datafile commentschar ""
set title "I/O Transfer Utilization"
set xdata time
set grid ytics
set timefmt "%Y-%m-%d %H:%M:%S"
set datafile separator ";"
set terminal jpeg size 1000,1000
set output sprintf("%s/io.png", outdir)
set xlabel "Time"
set ylabel "Number of I/O transfers per second"
set ytics nomirror
set y2label "Data Per Second (in blocks/second, block=512bytes)"
set y2tics nomirror
set ytics
# y2tics sets the increment between ticks, not their number
set y2tics autofreq

set xtics rotate
set key below
#set grid
set grid xtics ytics
# hostname;interval;timestamp;tps;rtps;wtps;bread/s;bwrtn/s
plot datafile using 3:5 axis x1y1  title "transfers/s" with lines, \
	datafile using 3:4  axis x1y1 title "r-reqs/s" with lines, \
	datafile using 3:5 axis x1y1 title "w-req/s" with lines, \
	datafile using 3:6  axis x1y2 title "block-read/s" with lines, \
	datafile using 3:7 axis x1y2 title "block-wrtn/s" with lines


