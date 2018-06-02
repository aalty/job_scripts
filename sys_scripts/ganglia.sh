#!/bin/bash
#echo $1
start_epoch=$2
end_epoch=$3

cd /var/lib/ganglia/rrds/Athena/$1
cpu_user_avg=$(rrdtool graph dummy --start=$start_epoch --end=$end_epoch DEF:x=cpu_user.rrd:sum:AVERAGE VDEF:xa=x,AVERAGE PRINT:xa:%lf | sed -n 2p)
cpu_user_max=$(rrdtool graph dummy --start=$start_epoch --end=$end_epoch DEF:x=cpu_user.rrd:sum:AVERAGE VDEF:xa=x,MAXIMUM PRINT:xa:%lf | sed -n 2p)

bytes_in_avg=$(rrdtool graph dummy --start=$start_epoch --end=$end_epoch DEF:x=bytes_in.rrd:sum:AVERAGE VDEF:xa=x,AVERAGE PRINT:xa:%lf | sed -n 2p)
bytes_in_max=$(rrdtool graph dummy --start=$start_epoch --end=$end_epoch DEF:x=bytes_in.rrd:sum:AVERAGE VDEF:xa=x,MAXIMUM PRINT:xa:%lf | sed -n 2p)

bytes_out_avg=$(rrdtool graph dummy --start=$start_epoch --end=$end_epoch DEF:x=bytes_out.rrd:sum:AVERAGE VDEF:xa=x,AVERAGE PRINT:xa:%lf | sed -n 2p)
bytes_out_max=$(rrdtool graph dummy --start=$start_epoch --end=$end_epoch DEF:x=bytes_out.rrd:sum:AVERAGE VDEF:xa=x,MAXIMUM PRINT:xa:%lf | sed -n 2p)

mem_total_avg=$(rrdtool graph dummy --start=$start_epoch --end=$end_epoch DEF:x=mem_total.rrd:sum:AVERAGE VDEF:xa=x,AVERAGE PRINT:xa:%lf | sed -n 2p)
mem_total_max=$(rrdtool graph dummy --start=$start_epoch --end=$end_epoch DEF:x=mem_total.rrd:sum:AVERAGE VDEF:xa=x,MAXIMUM PRINT:xa:%lf | sed -n 2p)

mem_free_avg=$(rrdtool graph dummy --start=$start_epoch --end=$end_epoch DEF:x=mem_free.rrd:sum:AVERAGE VDEF:xa=x,AVERAGE PRINT:xa:%lf | sed -n 2p)
mem_free_min=$(rrdtool graph dummy --start=$start_epoch --end=$end_epoch DEF:x=mem_free.rrd:sum:AVERAGE VDEF:xa=x,MINIMUM PRINT:xa:%lf | sed -n 2p)
mem_used_avg=$(awk '{printf "%.6f\n", $1-$2}' <<<"$mem_total_avg $mem_free_avg")
mem_used_max=$(awk '{printf "%.6f\n", $1-$2}' <<<"$mem_total_max $mem_free_min")

output="----- Ganglia info from $1 -----\n
cpu_user_avg: $cpu_user_avg\n
cpu_user_max: $cpu_user_max\n
bytes_in_avg: $bytes_in_avg\n
bytes_in_max: $bytes_in_max\n
bytes_out_avg: $bytes_out_avg\n
bytes_out_max: $bytes_out_max\n
mem_total_avg: $mem_total_avg\n
mem_total_max: $mem_total_max\n
mem_free_avg: $mem_free_avg\n
mem_free_min: $mem_free_min\n
mem_used_avg: $mem_used_avg\n
mem_used_max: $mem_used_max"

echo -e $output
