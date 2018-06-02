#!/bin/bash
jpid_log=./log/job_pid.log
jm_log=./log/job_monitor.log
jd_log=./log/job_dispatcher.log
is_log=./log/iperf_server.log
iotopd_sh=~/job_scripts/sys_scripts/iotop_daemon.sh

job_dispatcher_pid=$(cut -d ':' -f 2 <<< "$(grep job_dispatcher_pid $jpid_log)")
iperf_server_pid=$(cut -d ':' -f 2 <<< "$(grep iperf_server_pid $jpid_log)")
job_monitor_pid=$(cut -d ':' -f 2 <<< "$(grep job_monitor_pid $jpid_log)")

IFS=$' ' read -ra jd_fork_pid <<< $(ps -ef | grep $job_dispatcher_pid | awk -v pid="$job_dispatcher_pid" '{if ($3==pid) print $2}')
for id in ${jd_fork_pid[@]}
do
        echo $id
        kill $id
done

IFS=$' ' read -ra io_node <<< $(awk -v io="iotop_pid:" '{if ($2==io) print $1}' $jpid_log)
for n in ${io_node[@]}
do 
	iotop_pid=$(awk -v n="$n" '{if ($1==n) print $3}' $jpid_log)
	ssh $n $iotopd_sh -m 0 -p $iotop_pid
done

kill $job_dispatcher_pid

IFS=$' ' read -ra is_fork_pid <<< $(ps -ef | grep $iperf_server_pid | awk -v pid="$iperf_server_pid" '{if ($3==pid) print $2}')
for id in ${is_fork_pid[@]}
do 
	echo $id
	kill $id 
done
kill $iperf_server_pid

IFS=$' ' read -ra jm_fork_pid <<< $(ps -ef | grep $job_monitor_pid | awk -v pid="$job_monitor_pid" '{if ($3==pid) print $2}')
for id in ${jm_fork_pid[@]} 
do 
	echo $id
	kill $id
done
kill $job_monitor_pid

rm $jpid_log $jm_log $jd_log $is_log
