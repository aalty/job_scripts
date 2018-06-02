#!/bin/bash

# check COMPLETED or FAILED 
# job_id=$1
# sacct -c 2>&1 | awk '{if ($1 == $job_id) print $7;}'

slurm_log_by_id=$(grep $1 /var/log/slurm/job_completions)
#echo $slurm_log_by_id
#grep JobId=48 /var/log/slurm/job_completions | cut -d ' ' -f 4 | cut -d '=' -f 2
echo +++++++++++++++ Slurm Job +++++++++++++++
job_name=$(echo $slurm_log_by_id | cut -d ' ' -f 4 | cut -d '=' -f 2 | cut -d '.' -f 1 ) 
IFS="_" read -ra job_argu <<< "$job_name"
echo ----- job type -----
echo ${job_argu[0]}
echo ----- job args -----
echo ${job_argu[1]} ${job_argu[2]}

echo ----- job node -----
job_node=$(echo $slurm_log_by_id | cut -d ' ' -f 10 | cut -d '=' -f 2 ) 
if [[ $job_node == *[\[\]]* ]]; then
	nodes=$(echo $job_node | cut -d "[" -f2 | cut -d "]" -f1)
	IFS=", " read -ra node <<< "$nodes"
	#echo ${#nodes[@]}	# 03 05
	for n in "${node[@]}"; do echo athena$n; done
else 
	node=$(echo $job_node | cut -d "[" -f2 | cut -d "]" -f1)
	#echo ${#node[@]}	#athena02
	echo $node
fi

job_start=$(echo $slurm_log_by_id | cut -d ' ' -f 8 | cut -d '=' -f 2)
job_end=$(echo $slurm_log_by_id | cut -d ' ' -f 9 | cut -d '=' -f 2)
job_start_epoch=$(date "+%s" -d "$job_start")
job_end_epoch=$(date "+%s" -d "$job_end")
echo ----- start epoch -----
echo $job_start_epoch
echo ----- end epoch -----
echo $job_end_epoch-----

smart_sh=~/job_scripts/sys_scripts/smart.sh
ganglia_sh=~/job_scripts/sys_scripts/ganglia.sh

echo +++++++++++++++ SMART/Ganglia +++++++++++++++++
if [[ ${#node[@]} -eq 1 ]]; then
	#echo ${node:6}
	$smart_sh ${node:6}
	$ganglia_sh ${node:6}
else
	for n in "${node[@]}"
	do
		#echo $n
		$smart_sh $n
		$ganglia_sh $n
	done
fi


./tmp.sh


