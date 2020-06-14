#!/usr/bin/ksh
#
###################################################################################
#
# Name:                 add_disks
#
# Paramters:		1st	number of disks to be added
#			2nd	starting from this disk
#
# Description:          This utility does the complete processing for adding a disk.
#			It will...
#				format the disk to label
#				write a new volume table of contents
#				gets vxconfigd to look for new disks
#				adds the disk to veritas
#			If the disk group does not exist it will fail.
#			If the disk is already configured it will fail.
#			If it comes across any errors it will fail with
#			the appropriate message.
#
# Exit codes:		1	Invalid syntax
#			2	Disk already exisits in Veritas
#			3	Error with call to vxdisksetup
#			4	Error with call to vxdg
#			5	Disk group does not exist
#			6	Error with call to format
#			7	Error with call to fmthard
#			8	Error occurred enabling vxconfigd through vxdctl
#
# Author:               Anthony Firmin
#
# Date Written:         23/5/02
#
# Change history:
#
#
###################################################################################
#

# set -x

#################################################
################# FUNCTIONS #####################
#################################################

usage() {

print "
UX: add_disks: ERROR: invalid syntax.
usage:  add_disks  [ number of disks ] [ starting at disk number ]
"
exit 1

}

#################################################
################# MAIN CODE #####################
#################################################

print ""
print "Starting multiple add disk facility"
print ""

#################################################
# setup all the necessary variables...

disk_group=datadg

if vxprint -Ath | grep "dg $disk_group" > /dev/null
then
	:
else
	print ""
	print "Error: disk group "$disk_group" does not exist"
	print "Exiting..."
	print ""
	exit 5
fi

print "label" > /tmp/format.com
format_file=/tmp/format.com

format_log=/tmp/format.log
cat /dev/null > $format_log

vtoc_skel=/usr/local/bin/vtoc.skel

vtoc_log=/tmp/vtoc.log
cat /dev/null > $vtoc_log

vxprint_file=/tmp/vxprint.out

#################################################
# assess the parameters passed...

if [[ $# -ne 2 ]]
then
	usage
	exit 1
fi

number_of_disks=$1
starting_disk=$2

vxprint -Ath > $vxprint_file

# check the disk(s) are not already known the Veritas

for i in $(just_a_number.ksh $number_of_disks $starting_disk)
do
	disk="c4t21d"$i
	if grep $disk $vxprint_file
	then
		print ""
		print "Disk already exists in Veritas"
		print "Exiting..."
		print ""
		exit 2
	fi
done

disk=""

#################################################
# 
# check to see if this is the first disk for datadg
# if it is then set the disk number to 0 (it will be
# incremented later before use !!!

datadg_no=$(vxprint -Ath | grep "dm datadg" | tail -1 | awk '{print $2}' | sed -e 's/datadg//')

if [[ $datadg_no = "" ]]
then
      datadg_no=0
fi

#################################################
# for each disk to be set up we
#	label the disk using format
#	set up a new volume table of contents using fmthard

print "Starting disk formatting..."
print ""

for i in $(just_a_number.ksh $number_of_disks $starting_disk)
do

	disk="c4t21d"$i
	disk_name="c4t21d"$i"s2"
	full_disk_name="/dev/rdsk/"$disk_name

	print "Formatting -> "$disk

        format -f $format_file $disk_name >> $format_log

	if [[ $? -ne 0 ]]
	then
		print ""
		print "Error with format"
		print "Disk "$disk_name
		print ""
		exit 6
	fi

        fmthard -s $vtoc_skel $full_disk_name >> $vtoc_log

	if [[ $? -ne 0 ]]
	then
		print ""
		print "Error with fmthard"
		print "Disk "$full_disk_name
		print ""
		exit 7
	fi

done

#################################################
# Having formatted the disks we now instruct
# Veritas to scan for any new disks that may have
# been added since vconfigd was last started.

print ""
print "Re-enabling vxconfigd..."

# vxdctl enable

if [[ $? -ne 0 ]]
then
	print ""
	print "Error enabling the vxconfigd through vxdctl"
	print ""
	exit 8
fi

print ""
print "vxconfigd re-enabled..."
print ""

#################################################
# The disks are now visible to Veritas so we now
# undertake the following tasks...
# 	initialise the disk for use with Veritas using vxdiskadd
#	add the disk into the disk group using vxdg

for i in $(just_a_number.ksh $number_of_disks $starting_disk)
do

	disk="c4t21d"$i
	disk_name="c4t21d"$i"s2"
	full_disk_name="/dev/rdsk/"$disk_name

	print "Adding "$disk" to Veritas "

	/etc/vx/bin/vxdisksetup -i $disk

	if [[ $? -ne 0 ]]
	then
		print ""
		print "Error with vxdisksetup"
		print "Disk "$disk
		print ""
		exit 3
	fi

	let datadg_no=$datadg_no+1
	print "Adding "$disk" as datadg"$datadg_no" to diskgroup "$disk_group

	vxdg -g $disk_group adddisk datadg$datadg_no=$disk

	if [[ $? -ne 0 ]]
	then
		print ""
		print "Error with vxdg"
		print "Disk group "$disk_group
		print "Disk "$disk
		print "datadg"$datadg_no
		print ""
		exit 4
	fi
	print ""
done

print "Multiple add disk facility completed !!!"
print ""

#################################################

exit 0
