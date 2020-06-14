#!/usr/bin/sh
#
###################################################################################
#
# Name:                 sar_graph
#
# Description:          The script will generate an output file for input into 
#			MS Excel in the format of date, time (x axis) and 
#			parameter (y axis).
#
# Parameters:           1st     identifies the part of the process to run, -c is
#				for cpu, -m is for memory and -s is for swap.
#
#			2nd	number of weeks to produce graph for (a week being
#				the previous 7 header
#
#
# Author:               Anthony Firmin, FCCL
#
# Date Written:         8/4/02
#
# Change History:
#			18/4/02 Anthony Firmin
#			Ported to Zantos.
#
#
###################################################################################

# set -x

###################################################################################
##########################   FUNCTIONS   ##########################################
###################################################################################

usage() {

print "
UX: sar_graph.ksh - create a file of sar data for use in a graph: 
ERROR: invalid syntax.
usage:  sar_graph.ksh [[-c] [-m] [-s]] [[1] [2] [3] [4]]

"

}

#############

sar_cpu () {

today=$(date "+%y%m%d")
cat /dev/null > /tmp/${server_name}_sar_cpu.$today

cd /var/adm/sa

for i in $(ls -altr | grep sa | grep -v sar | awk '{print $9}' | tail -$tailer | head -$header)
do

	sar_date=$(sar -f $i | egrep "SunOS" | egrep -v "restarts" | awk '{print $6";"}' | sed -e "s/\//-/g")

	print $sar_date

	sar -f $i | egrep -v "usr|SunOS|freemem|Average" | sed -e "/^$/d" | awk '{print $1";"100 - $5}' | sed -e "s/^/$sar_date/g" >> /tmp/${server_name}_sar_cpu.$today

done 

chmod 777 /tmp/${server_name}_sar_cpu.$today

}

#############

sar_memory () {

today=$(date "+%y%m%d")
cat /dev/null > /tmp/${server_name}_sar_memory.$today

cd /var/adm/sa

for i in $(ls -altr | grep sa | grep -v sar | awk '{print $9}' | tail -$tailer | head -$header)
do

	sar_date=$(sar -r -f $i | egrep "SunOS" | egrep -v "restarts" | awk '{print $6";"}' | sed -e "s/\//-/g")

	print $sar_date

	sar -r -f $i | egrep -v "usr|SunOS|freemem|Average" | sed -e "/^$/d" | awk '{print $1";"$2}' | sed -e "s/^/$sar_date/g" >> /tmp/${server_name}_sar_memory.$today

done 

chmod 777 /tmp/${server_name}_sar_memory.$today

}

#############

sar_swap () {

# set -x

today=$(date "+%y%m%d")
cat /dev/null > /tmp/${server_name}_sar_swap.$today

cd /var/adm/sa

for i in $(ls -altr | grep sa | grep -v sar | awk '{print $9}' | tail -$tailer | head -$header)
do

	sar_date=$(sar -r -f $i | egrep "SunOS" | egrep -v "restarts" | awk '{print $6";"}' | sed -e "s/\//-/g")

	print $sar_date

	sar -r -f $i | egrep -v "usr|SunOS|freemem|Average" | sed -e "/^$/d" | awk '{print $1";"$3}' | sed -e "s/^/$sar_date/g" >> /tmp/${server_name}_sar_swap.$today

done 

chmod 777 /tmp/${server_name}_sar_swap.$today

}

###################################################################################
#######################   END OF FUNCTIONS   ######################################
###################################################################################

###################################################################################
##########################   MAIN CODE   ##########################################
###################################################################################

# set up the env...

PATH=/usr/ccs/bin:/usr/bin:/usr/sbin:/usr/ucb:/etc::.:/usr/local/bin

server_name=`uname -n`

# Validate number of parameters and its value...

echo $#
if [ $# != 2 ]
then
	usage
	exit 1
fi

# validate the second parameter first, the header and trailer values determine the 
# number of files and days to be processed...

param2=$2

case $param2 in
	1)
		header=7
		tailer=8
		;;
	2)
		header=7
		tailer=16
		;;
	3)
		header=7
		tailer=23
		;;
	4)
		header=7
		tailer=30
		;;
	*)
		usage
		exit 1
esac

param1=$1

case $param1 in
	-c)
		sar_cpu
		;;
	-m)
		sar_memory
		;;
	-s)
		sar_swap
		;;
	*)
		usage
		exit 1
		;;
esac

exit 0
