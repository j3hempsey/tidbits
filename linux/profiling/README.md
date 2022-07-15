# Linux Profiling

## Profiling Using `sar`

`sar` is provided by the `sysstat` package and provides very good metrics into
system utilization with very low overhead. Using a combination of `sar` (to do
capture), `sadf` (to do data conversion), and `gnuplot` to do plotting, we have
a very simple but powerful performance analysis tool.

### Prerequisites

```
sudo apt install sysstat gnuplot
```

### Getting Started

Starting the `sysstat` service will run continuous (low overhead) data capture
on a device. This can then be used later for historical performance analysis,
i.e. see how the device did over the course of the past day.

To perform "online" capture (i.e. analyze the impact a file write workload has
on a system), you can run `sar -o <filename> -A <interval>` to capture a
complete picture of the system's performance. Using the tools in this directory
assumes that you have done a complete system capture. It is assumed that if you
want to use these tools, but do not want to capture all data (i.e only capture
CPU statistics), that you know how to manipulate and use `sar` in such a way
that you can capture only the data you want to be used compatibaly (or
incompatibly) with the tools here.

