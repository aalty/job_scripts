#!/bin/bash
sbatch_out_dir=~/job_scripts/sbatch_outfile/
slurm_sh=~/job_scripts/sys_scripts/slurm.sh
smart_sh=~/job_scripts/sys_scripts/smart.sh
ganglia_sh=~/job_scripts/sys_scripts/ganglia.sh
iotop_sh=~/job_scripts/sys_scripts/iotop.sh
sacct_log=~/job_scripts/sacct_log


function record_job {	
	job_id=$1
	echo $job_id is completed!
	slurm_record=$($slurm_sh $job_id)
	echo "$slurm_record"

	job_type=$(echo "$slurm_record" | grep "job type" | cut -d ':' -f 2)
	job_args=$(echo "$slurm_record" | grep "job args" | cut -d ':' -f 2)
	job_node=$(echo "$slurm_record" | grep "job node" | cut -d ':' -f 2)
	IFS=" " read -ra node <<< "$job_node"

	start_epoch=$(echo "$slurm_record" | grep "start epoch" | cut -d ':' -f 2)
	end_epoch=$(echo "$slurm_record" | grep "end epoch" | cut -d ':' -f 2)

	for n in ${node[@]}
	do
		smart_record=$($smart_sh $n) 
		echo "$smart_record"
		raw_read_error_rate=$(echo "$smart_record" | grep "Raw_Read_Error_Rate" | cut -d ':' -f 2)
		spin_up_time=$(echo "$smart_record" | grep "Spin_Up_Time" | cut -d ':' -f 2)
		reallocated_sector_ct=$(echo "$smart_record" | grep "Reallocated_Sector_Ct" | cut -d ':' -f 2)
		seek_error_rate=$(echo "$smart_record" | grep "Seek_Error_Rate" | cut -d ':' -f 2)
		power_on_hours=$(echo "$smart_record" | grep "Power_On_Hours" | cut -d ':' -f 2)
		temperature_celsius=$(echo "$smart_record" | grep "Temperature_Celsius" | cut -d ':' -f 2)
		
		ganglia_record=$($ganglia_sh $n $start_epoch $end_epoch)
		echo "$ganglia_record"
		cpu_user_avg=$(grep "cpu_user_avg" <<< "$ganglia_record" | cut -d ':' -f 2)	
		cpu_user_max=$(grep "cpu_user_max" <<< "$ganglia_record" | cut -d ':' -f 2)	
		bytes_in_avg=$(grep "bytes_in_avg" <<< "$ganglia_record" | cut -d ':' -f 2)	
		bytes_in_max=$(grep "bytes_in_max" <<< "$ganglia_record" | cut -d ':' -f 2)	
		bytes_out_avg=$(grep "bytes_out_avg" <<< "$ganglia_record" | cut -d ':' -f 2)	
		bytes_out_max=$(grep "bytes_out_max" <<< "$ganglia_record" | cut -d ':' -f 2)	
		#echo $bytes_out_max
		mem_used_avg=$(grep "mem_used_avg" <<< "$ganglia_record" | cut -d ':' -f 2)	
		mem_used_max=$(grep "mem_used_max" <<< "$ganglia_record" | cut -d ':' -f 2)	

		iotop_record=$(ssh $n $iotop_sh $n $start_epoch $end_epoch)
		echo "$iotop_record"
		io_read_avg=$(grep "io_read_avg" <<< "$iotop_record" | cut -d ':' -f 2)
		io_read_max=$(grep "io_read_max" <<< "$iotop_record" | cut -d ':' -f 2)
		io_write_avg=$(grep "io_write_avg" <<< "$iotop_record" | cut -d ':' -f 2)
		io_write_max=$(grep "io_write_max" <<< "$iotop_record" | cut -d ':' -f 2)
		#echo $job_type $io_write_max
		mysql my_experiment <<< "INSERT INTO test_expe (job_id, job_type, job_args, job_node, start_epoch, end_epoch, raw_read_error_rate, spin_up_time, reallocated_sector_ct, seek_error_rate, power_on_hours, temperature_celsius, cpu_user_avg, cpu_user_max, bytes_in_avg, bytes_in_max, bytes_out_avg, bytes_out_max, mem_used_avg, mem_used_max, io_read_avg, io_read_max, io_write_avg, io_write_max) VALUES ('$job_id', '$job_type', '$job_args', '$n', '$start_epoch', '$end_epoch', '$raw_read_error_rate', '$spin_up_time', '$reallocated_sector_ct', '$seek_error_rate', '$power_on_hours', '$temperature_celsius', '$cpu_user_avg', '$cpu_user_max', '$bytes_in_avg', '$bytes_in_max', '$bytes_out_avg', '$bytes_out_max', '$mem_used_avg', '$mem_used_max', '$io_read_avg', '$io_read_max', '$io_write_avg', '$io_write_max');"

	done

	
	
	#echo "$record" | grep "job args"
}


while true
do
	last_jid=$(cat $sacct_log)
	sacct -c > $sacct_log 2> /dev/null
	last_nth=$(awk -v last_jid="$last_jid" '{if ($1==last_jid) print NR}' $sacct_log) 
	IFS=' ' read -ra new_id <<< $(tail -n +$((last_nth+1)) $sacct_log | awk -v comp="COMPLETED" '{if ($7==comp) print $1}')
	for id in ${new_id[@]}
	do
		record_job $id
	done
	if [ -z "$id" ];then
		echo $last_jid > $sacct_log
	else
		echo $id > $sacct_log
	fi

	sleep 10m
done

	

#inotifywait -m -e close_write $sbatch_out_dir --format '%f'|
#while read filename
#do
##filename=slurm-183.out 
#	jid=$(echo $filename | cut -d '-' -f 2 | cut -d '.' -f 1)
#	echo $jid
#	if [ "$(sacct -c 2>&1 | awk -v s_style="$jid" '{if ($1==s_style) print $7}')" == "COMPLETED" ];then
#		record_job $jid
#	else
#		echo $jid not completed yet.
#	fi
#done

	

 
