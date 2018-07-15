#!/bin/bash
#exec 3> >(sed "s/^/$(date +'%Y%m%d%H%M%S ')/" >> /tmp/tmp_log)
#sudo iotop -boqqk >&3 & 
#iotop_pid=$!
#echo $iotop_pid
iotop_log=/tmp/iotop_log
while [ -n "$1" ]
do
       case "$1" in
               -m) mode="$2"
              shift ;;
	       -p) io_pid="$2"
	      shift ;;
       esac
       shift
done

if [[ $mode == 1 ]]; then
	sudo iotop -boqqk | awk '{ print strftime("%s "), $0; fflush(); }' >> $iotop_log &
	iotop_pid=$!
	echo $iotop_pid
elif [[ $mode == 0 ]]; then
	echo $io_pid
	IFS=$' ' read -ra io_fork_pid <<< $(ps -ef | grep $io_pid | awk -v pid="$io_pid" '{if ($3==pid) print $2}')
	for id in ${io_fork_pid[@]}
	do 
		echo $id
		sudo kill $id
	done
	sudo kill $io_pid
	> $iotop_log
fi
