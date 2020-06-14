#!/usr/bin/ksh
#
###############################################################################
# Name:		sar_disks_converter
# Date:		June 2001
# Author:	Anthony Firmin, FCCL
# Purpose:	To convert system disk numbers to mount points
#
# Change History:
# Name:
# Date:
# Reason:
#
###############################################################################

# set -x

###############################################################################
########################### FUNCTIONS #########################################
###############################################################################

sd_list () {

iostat -E | awk '{ x = 1 } {
	if ( $1 ~ /sd[0-9][0-9]/ )
		sd_array[x] = $1
	if ( $1 == "Vendor:" && $2 == "EMC") {
		serial_array[x] = $9
		print sd_array[x], serial_array[x]
		}
	else
		name = "fred"
} {}' > /tmp/sd.out

}


c_list () {

iostat -En | awk '{ x = 1 } {
	if ( $1 ~ /c4t21d[0-9][0-9]*/ )  {
		dev_array[x] = $1
	}
	if ( $1 == "Vendor:" && $2 == "EMC") {
		serial_array[x] = $9
		print dev_array[x], serial_array[x]
		}
	else
		name = "fred"
} {}' > /tmp/c.out

}

###############################################################################
########################### MAIN CODE #########################################
###############################################################################

# Generate the device info files by running the following functions...

# set -x
sd_list
c_list

# See if the system device no is in the sd.out file and get the disks
# serial number...

if [[ $1 = "sd"[0-9][0-9] || $1 = "sd"[0-9][0-9][0-9] ]]
then
   if grep $1 /tmp/sd.out > /dev/null 2>&1
   then
	serial_no=$(grep $1 /tmp/sd.out | awk '{print $2}')

	device_no=$(grep $serial_no /tmp/c.out | awk '{print $1}')

	vxprint -Ath | grep $device_no" " > /tmp/vx.out
	for i in $(cat /tmp/vx.out | awk '{print $3}' | sed -e "s/-[0-9][0-9]//")
	do
		df=$(df -k | grep $i | awk '{print $6}')
		print $df
	done
   else
	print $1 " - invalid disk number entered"
   fi
else
   print $1 " - incorrect parameter entered"
fi

# tidyup...

rm /tmp/vx.out > /dev/null 2>&1
rm /tmp/sd.out > /dev/null 2>&1
rm /tmp/c.out > /dev/null 2>&1
