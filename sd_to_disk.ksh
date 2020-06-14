#!/usr/bin/ksh
#
###############################################################################
# Name:		sd_to_disk
# Date:		June 2001
# Author:	Anthony Firmin, FCCL
# Purpose:	To convert system disk numbers to logical disk numbers
#		and additionally retrieve Veritas disk info and volume info
#		if relevant.
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

# Check the correct number of parameters entered...

if [[ $# < 1 || $# > 1 ]]
then
#	print "Error, incorrect number of parameters entered"
	print ""
	print "sd_to_disk:  ERROR: Invalid syntax" 
	print "usage:  sd_to_disk diskname "
    	print "  e.g.  sd_to_disk sd00"
	print ""
	return 1
fi

# Generate the device info files by running the following functions...

sd_list
c_list

# See if the system device no is in the sd.out file and get the disks
# serial number...

serial_no=$(grep $1 /tmp/sd.out | awk '{print $2}')

if [[ $? != 0 || $serial_no == "" ]]
then
	print ""
	print "sd_to_disk:  ERROR: Invalid syntax" 
	print "  sd number, $1, is not known to the system"
	print ""
	return 1
fi

# Having got the serial number, get the device number...

device_no=$(grep $serial_no /tmp/c.out | awk '{print $1}')

if [[ $? != 0 || $device_no == "" ]]
then
	print ""
	print "sd_to_disk:  ERROR: Invalid syntax" 
	print "  device number for $1, is not known to the system"
	print ""
	return 1
fi

# Now start the reporting process of what we have gathered so far...

print ""
print "sd to disk translator"
print "====================="
print ""
print "system device is   " $1
print "logical disk is    " $device_no
print ""

# Now work out what it is in Veritas and report that as well...

print "Veritas Info"
print "============"

vxprint -Ath | grep $device_no"s2" > /tmp/vx.out
no_lines=$(cat /tmp/vx.out | wc -l)

if [[ $no_lines -eq 1 ]]
then
	print ""
	print "Member of data group        $(cat /tmp/vx.out | head -1 | awk '{print $2}')"
else
	print ""
	print "Disk is not a member of any data group" 
	print ""
	exit
fi

vxprint -Ath | grep $device_no" " > /tmp/vx.out
no_lines=$(cat /tmp/vx.out | wc -l)

if [[ $no_lines -eq 1 ]]
then
	vol=$(cat /tmp/vx.out | tail -1 | awk '{print $3}' | sed -e "s/-[0-9][0-9]//")
	print "Data group is in volume    " $vol
	df=$(df -k | grep $vol | awk '{print $6}')
	print "Which is mounted as        " $df
	print ""
fi

if [[ $no_lines -eq 0 ]]
then
	print ""
	print "Disk is not allocated to a Veritas volume"
	print ""
fi

if [[ $no_lines -gt 1 ]]
then
	for i in $(cat /tmp/vx.out | awk '{print $3}' | sed -e "s/-[0-9][0-9]//")
	do
		print ""
		print "Data group is in volume    " $i
		df=$(df -k | grep $i | awk '{print $6}')
		print "Which is mounted as        " $df
		print ""
	done
fi


# tidyup...

rm /tmp/vx.out > /dev/null 2>&1
rm /tmp/sd.out > /dev/null 2>&1
rm /tmp/c.out > /dev/null 2>&1
