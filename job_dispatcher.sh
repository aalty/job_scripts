#!/bin/bash
hpl_dir=./hpl_scripts/
ior_dir=./ior_scripts/
iperf_dir=./iperf_scripts/
sbatch_out=./sbatch_outfile/slurm-%j.out
jpid_log=./log/job_pid.log
iotopd_sh=~/job_scripts/sys_scripts/iotop_daemon.sh

worker_num=13
IFS=" " read -ra workers <<< $(seq -w 02 14)

IFS="," read -ra hpl_N <<< "$(grep hpl_N job_args | cut -d ' ' -f 2)"
#echo ${hpl_N[3]}
IFS="," read -ra hpl_NB <<< "$(grep hpl_NB job_args | cut -d ' ' -f 2)"
IFS="," read -ra ior_t <<< "$(grep ior_t job_args | cut -d ' ' -f 2)"
IFS="," read -ra ior_b <<< "$(grep ior_b job_args | cut -d ' ' -f 2)"
IFS="," read -ra iperf_b <<< "$(grep iperf_b job_args | cut -d ' ' -f 2)"
IFS="," read -ra iperf_n <<< "$(grep iperf_n job_args | cut -d ' ' -f 2)"

#for i in ${ior_t[@]}; do echo $i; done

#init_j=36
while true 
do
	for ((j=0; j<48; j++)) do
		for ((i=0;i<$worker_num;i++)) do
			#if (($i == 8)); then
			#	continue
			#fi
			ran=$(((j/16)+1))
			
			#ran=$(((RANDOM%3)+1))
			#echo $ran
			if (($ran == 1)); then
				ran_N=$j
				#ran_N=$(((RANDOM%16)))
				ran_NB=$(((ran_N/4)))
				#echo $ran_N $ran_NB
				hpl_file="$hpl_dir${ran}_${hpl_N[$ran_N]}_${hpl_NB[$ran_NB]}.sh"
				echo $hpl_file
				#tmp_node="athena${workers[$i]}"
				#echo $tmp_node
				sbatch -o $sbatch_out -w athena${workers[$i]} $hpl_file
				#output=$(sbatch $hpl_file)
				#jid=$(echo $output | cut -d ' ' -f 4)
				#echo "Submitted batch job -->" $jid  
			elif (($ran == 2)); then
				ior_file=" $ior_dir${ran}_${ior_t[((($j-16) / 4))]}_${ior_b[(($j % 4))]}.sh"
				#ior_file=" $ior_dir${ran}_${ior_t[(($RANDOM % 4))]}_${ior_b[(($RANDOM % 4))]}.sh"
				echo $ior_file
				sbatch -o $sbatch_out -w athena${workers[$i]} $ior_file
				#output=$(sbatch 2_1m_1g.sh)
				#jid=$(echo $output | cut -d ' ' -f 4)
				#echo "Submitted batch job -->" $jid
			else
				iperf_file="$iperf_dir${ran}_${iperf_b[((($j-32) / 4))]}_${iperf_n[(($j % 4))]}.sh"
				#iperf_file="$iperf_dir${ran}_${iperf_b[(($RANDOM % 4))]}_${iperf_n[(($RANDOM % 4))]}.sh"
				echo $iperf_file
				sbatch -o $sbatch_out -w athena${workers[$i]} $iperf_file
				#output=$(sbatch 3_256k_64k.sh)
				#jid=$(echo $output | cut -d ' ' -f 4)
				#echo "Submitted batch job -->" $jid		
			fi
		done
		
		sleep 10m
	done

	#cleaup iotop log
	for ((n=0; n<$worker_num; n++))
	do
		iotop_pid=$(awk -v n="athena${workers[$n]}" '{if ($1==n) print $3}' $jpid_log)
		ssh athena${workers[$n]} $iotopd_sh -m 0 -p $iotop_pid
	done

	#reset iotop log and other pid log
	job_dispatcher_pid=$(cut -d ':' -f 2 <<< "$(grep job_dispatcher_pid $jpid_log)")
	echo "$(cat $jpid_log | head -2)" > $jpid_log
	for ((n=0; n<$worker_num; n++))
	do
		iotop_pid=$(ssh athena${workers[$n]} $iotopd_sh -m 1)
		echo "athena${workers[$n]} iotop_pid: $iotop_pid" >> $jpid_log
	done
	echo "job_dispatcher_pid: $job_dispatcher_pid" >> $jpid_log

	#init_j=0
done

