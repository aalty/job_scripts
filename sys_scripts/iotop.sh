#!/bin/bash
iotop_log=/tmp/iotop_log
start_epoch=$2
end_epoch=$3
total_read="0.00"
total_write="0.00"
max_read="0.00"
max_write="0.00"
epoch=0
for ((i=$start_epoch; i<=$end_epoch; i++))
do
	#echo $i
	tmp_read=$(awk -F' ' -v start_epoch="$i" '{if ($1==start_epoch && $2=="Total") print $6}' $iotop_log)
	tmp_write=$(awk -F' ' -v start_epoch="$i" '{if ($1==start_epoch && $2=="Total") print $13}' $iotop_log)
	if [[ $tmp_write ]];then
		if [[ $(awk -v a="$tmp_read" -v b="$max_read" 'BEGIN{print(a>b)}') == 1 ]];then max_read=$tmp_read; fi
		if [[ $(awk -v a="$tmp_write" -v b="$max_write" 'BEGIN{print(a>b)}') == 1 ]];then max_write=$tmp_write; fi

		total_read=$(awk '{printf "%.2f", $1+$2}' <<< "$tmp_read $total_read")
		total_write=$(awk '{printf "%.2f", $1+$2}' <<< "$tmp_write $total_write")
		epoch=$(($epoch + 1))		
	fi
	
done

if [[ $epoch != '0' ]]; then
	avg_read=$(awk '{printf "%.2f", $1/$2}' <<< "$total_read $epoch")
	avg_write=$(awk '{printf "%.2f", $1/$2}' <<< "$total_write $epoch")
fi

output="----- iotop info from $1 -----\n
io_read_avg: $avg_read\n
io_read_max: $max_read\n
io_write_avg: $avg_write\n
io_write_max: $max_write"

echo -e $output

