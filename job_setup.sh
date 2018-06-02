#!/bin/bash
job_monitor=./job_monitor.sh
job_dispatcher=./job_dispatcher.sh
iperf_server=./sys_scripts/iperf_server.sh
iotop_daemon=~/job_scripts/sys_scripts/iotop_daemon.sh
start_worker=02
end_worker=14
jpid_log=./log/job_pid.log
jm_log=./log/job_monitor.log
jd_log=./log/job_dispatcher.log
is_log=./log/iperf_server.log

#while [ -n "$1" ]
#do 
#	case "$1" in
#		-m) mode="$2"
#		shift ;;
#	esac
#	shift
#done


#echo "now mode: on"
$job_monitor &> $jm_log &
job_monitor_pid=$!
echo "job_monitor_pid: $job_monitor_pid" >> $jpid_log

$iperf_server > $is_log &
iperf_server_pid=$!
echo "iperf_server_pid: $iperf_server_pid" >> $jpid_log

for i in $(seq -w $start_worker $end_worker)
do 
	iotop_pid=$(ssh athena$i $iotop_daemon -m 1)
	echo "athena$i iotop_pid: $iotop_pid" >> $jpid_log
done

$job_dispatcher > $jd_log &
job_dispatcher_pid=$!
echo "job_dispatcher_pid: $job_dispatcher_pid" >> $jpid_log
