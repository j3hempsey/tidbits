if (!exists("datafile")) datafile='tmp.cpu.all.dat'
if (!exists("outdir")) outdir='cpu'
if (!exists("autorange")) autorange=0

set datafile commentschar ""
set title "Processor Utilization"
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set datafile separator ";"
set terminal jpeg size 1000,1000
set output sprintf("%s/cpu.all.png", outdir)
set xlabel "Time"
set ylabel "% Utilization"
set xtics rotate
set key below
set grid
if (autorange != 1) set yrange [0:100]
#%user;%nice;%system;%iowait;%steal;%idle
plot \
	for [i=0:6] datafile using 3:5+(i*7) title sprintf("CPU: %s %%user",i==0 ? "All" : sprintf("%d", i)) with lines, \
	for [i=0:6] datafile using 3:6+(i*7) title sprintf("CPU: %s %%nice",i==0 ? "All" : sprintf("%d", i)) with lines, \
	for [i=0:6] datafile using 3:7+(i*7) title sprintf("CPU: %s %%system",i==0 ? "All" : sprintf("%d", i)) with lines, \
	for [i=0:6] datafile using 3:8+(i*7) title sprintf("CPU: %s %%iowait",i==0 ? "All" : sprintf("%d", i)) with lines

set output sprintf("%s/cpu.user.png", outdir)
plot \
	for [i=0:6] datafile using 3:5+(i*7) \
		title sprintf("CPU: %s %%user",i==0 ? "All" : sprintf("%d", i)) with lines

set output sprintf("%s/cpu.nice.png", outdir)
plot \
	for [i=0:6] datafile using 3:6+(i*7) \
		title sprintf("CPU: %s %%nice",i==0 ? "All" : sprintf("%d", i)) with lines

set output sprintf("%s/cpu.system.png", outdir)
plot \
	for [i=0:6] datafile using 3:7+(i*7) \
		title sprintf("CPU: %s %%system",i==0 ? "All" : sprintf("%d", i)) with lines

set output sprintf("%s/cpu.iowait.png", outdir)
plot \
	for [i=0:6] datafile using 3:8+(i*7) \
		title sprintf("CPU: %s %%iowait",i==0 ? "All" : sprintf("%d", i)) with lines

