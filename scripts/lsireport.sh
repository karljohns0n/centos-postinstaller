#!/bin/sh
#
# LSI MegaRAID report for device and hard drives health. Compatible with SATA and SAS.
#
# by Karl Johnson
# karljohnson.it@gmail.com
#
# Version 1.2
#
# You should add a cron for this, such as:
# 0 7 * * 0 /bin/bash /opt/megeraid/lsireport.sh > /dev/null 2>&1
#

email="report@aerisnetwork.com"

if [ -f /opt/MegaRAID/MegaCli/MegaCli64 ]; then
    cli="/opt/MegaRAID/MegaCli/MegaCli64"
elif [ -f /opt/megaraid/megacli ]; then
     cli="/opt/megaraid/megacli"
else
  echo "megacli is not in /opt, please check"
  exit 1
fi

if [ ! -f /usr/bin/mutt ]; then
  echo "Mutt is not in /usr/bin, please check"
  exit 1
fi

$cli -AdpAllInfo -aALL > /tmp/AdpAllInfo.txt
numarrays=`grep "Virtual Drives" /tmp/AdpAllInfo.txt|awk '{print $4}'`
LSILOG="/tmp/lsireport.log"


### Basic information

echo -e "*****************************************************\n
LSI report for: `hostname`\n
Product: `grep "Product Name" /tmp/AdpAllInfo.txt|awk '{print $4,$5,$6,$7,$8}'`
Firmware version: `grep "FW Version" /tmp/AdpAllInfo.txt|awk '{print $4}'`
Driver version: `/sbin/modinfo megaraid_sas|grep "version:"|grep -v srcversion|awk '{print $2}'`\n" 3>&1 4>&2 >>$LSILOG 2>&1


### Status of all arrays

echo -e "\nStatus of all arrays" 3>&1 4>&2 >>$LSILOG 2>&1
i="0"
while [ $i -lt $numarrays ]
do
	echo " - Array #$i state is `$cli -LDInfo -L$i -aALL|grep State |awk '{print $3}'`" 3>&1 4>&2 >>$LSILOG 2>&1
	echo " - Array #$i `$cli -LDInfo -L$i -aALL|grep 'Current Cache Policy'`" 3>&1 4>&2 >>$LSILOG 2>&1
	i=$[$i+1]
done


### Status of all device errors

echo -e "\n\nStatus of all device errors 

Card `grep 'Memory Correctable Errors' /tmp/AdpAllInfo.txt`
Card `grep 'Memory Uncorrectable Errors' /tmp/AdpAllInfo.txt`" 3>&1 4>&2 >>$LSILOG 2>&1
$cli -PDList -aALL|egrep "Error Count|Failure Count" 3>&1 4>&2 >>$LSILOG 2>&1


### Status of all SMART

deviceids=`$cli -PDList -aAll | egrep "Device Id:"|awk '{print $3}'|sort -n`
disktype=`$cli -PDList -aAll|grep "PD Type"|awk '{print $3}'|head -n 1`

echo -e "\n\nStatus of all $disktype disk SMART\n" 3>&1 4>&2 >>$LSILOG 2>&1
while read line; do
   echo -e " - Drive $line:\n" 3>&1 4>&2 >>$LSILOG 2>&1
   if [ "$disktype" == "SATA" ]; then
   	        /usr/sbin/smartctl -a -d sat+megaraid,$line /dev/sda|egrep "Device Model:|SMART overall-health|Power_On_Hours|Temperature_Celsius|Reallocated_Event_Count|Current_Pending_Sector|Offline_Uncorrectable" 3>&1 4>&2 >>$LSILOG 2>&1
   elif [ "$disktype" == "SAS" ]; then
	        /usr/sbin/smartctl -a -d megaraid,$line /dev/sda|egrep "Product:|SMART Health|Current Drive Temperature|Elements in grown defect|Errors Corrected|algorithm|read:|write:|verify:|Non-medium" 3>&1 4>&2 >>$LSILOG 2>&1
   fi
   echo -e "\n" 3>&1 4>&2 >>$LSILOG 2>&1
done <<< "$deviceids"


### Dumping last 1000 lines of device events

echo -e "Finaly, the last 1000 lines of the event log for verification:\n" 3>&1 4>&2 >>$LSILOG 2>&1
$cli -AdpEventLog -GetEvents -f /dev/stdout -aALL|tail -n1000 3>&1 4>&2 >>$LSILOG 2>&1

echo -e "Here's the full LSI weekly report for `hostname`" | /usr/bin/mutt -a "$LSILOG" -s "LSI report for: `hostname`" -- $email


# Cleanup
rm -I /tmp/AdpAllInfo.txt /root/sent $LSILOG