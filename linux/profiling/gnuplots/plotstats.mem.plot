if (!exists("datafile")) datafile='tmp.mem.dat'
if (!exists("outdir")) outdir='mem'
if (!exists("autorange")) autorange=0

set datafile commentschar ""
set title "RAM Utilization"
set xdata time
#set grid ytics
set timefmt "%Y-%m-%d %H:%M:%S"
set datafile separator ";"
set terminal jpeg size 1000,1000
set output sprintf("%s/mem.png", outdir)
set xlabel "Time"
set y2label "% Utilization"
set ylabel "kb Utilization"
set ytics nomirror
set y2tics

if (autorange != 1) set yrange [0:16*1024*1024]
if (autorange != 1) set y2range [0:100]
# y2tics sets the increment between ticks, not their number
#set y2tics autofreq

set xtics rotate
set key below
set grid xtics ytics

# hostname;interval;timestamp;kbmemfree;kbavail;kbmemused;%memused;kbbuffers;kbcached;kbcommit;%commit;kbactive;kbinact;kbdirty
plot \
	datafile using 3:4  axis x1y1 title "kbfree" with lines, \
	datafile using 3:5 axis x1y1 title "kbavail" with lines, \
	datafile using 3:6 axis x1y1 title "kbused" with lines, \
	datafile using 3:7  axis x1y2 title "%memused" with lines, \
	datafile using 3:8 axis x1y1 title "kbbuff" with lines, \
	datafile using 3:9 axis x1y1 title "kbcached" with lines, \
	datafile using 3:10 axis x1y1 title "kbcommit" with lines, \
	datafile using 3:11 axis x1y2 title "%commit" with lines

