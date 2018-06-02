#!/bin/bash
file_loc=~/job_scripts/sys_scripts/smart_tmp/$1_smart.tmp
#echo $file_loc
ssh $1 sudo smartctl -a /dev/sda > $file_loc 
Raw_Read_Error_Rate=$(grep Raw_Read_Error_Rate $file_loc | awk '{print $10;}')
Spin_Up_Time=$(grep Spin_Up_Time $file_loc | awk '{print $10;}')
Reallocated_Sector_Ct=$(grep Reallocated_Sector_Ct $file_loc | awk '{print $10;}')
Seek_Error_Rate=$(grep Seek_Error_Rate $file_loc | awk '{print $10;}')
Power_On_Hours=$(grep Power_On_Hours $file_loc | awk '{print $10;}')
Temperature_Celsius=$(grep Temperature_Celsius $file_loc | awk '{print $10;}')


output="----- SMART info from $1 -----\n
Raw_Read_Error_Rate: $Raw_Read_Error_Rate\n
Spin_Up_Time: $Spin_Up_Time\n
Reallocated_Sector_Ct: $Reallocated_Sector_Ct\n
Seek_Error_Rate: $Seek_Error_Rate\n
Power_On_Hours: $Power_On_Hours\n
Temperature_Celsius: $Temperature_Celsius"

echo -e $output
