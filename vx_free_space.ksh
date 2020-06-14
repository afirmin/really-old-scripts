#!/usr/bin/ksh

# set -x

my_count=0

for j in $(/usr/sbin/vxprint -Ath | grep "dg " | awk '{print $2}')
do
	my_count=0

	for i in $(/usr/sbin/vxdg free | grep $j | awk '{print $6}')
	do
		let my_count=$my_count+$i
	done

	let total=$my_count/2159573
	if [[ $total -gt 0 ]]
	then
		print "Free space in $j is "$total "GB"
	else
		let total=$my_count/2159
		if [[ $total -eq 0 &&  $my_count -gt 0 ]]
		then
			total="< 1"
		fi
		print "Free space in $j is "$total "MB"
	fi
done
