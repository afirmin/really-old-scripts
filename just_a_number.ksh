#!/usr/bin/ksh
#
###################################################################################
#
# Name: 		jan - just a number generator
#
# Description:		Script to generate a sequence of numbers determined
#			determined by the length and starting point provided 
#			as optional parameters.
#			database refreshes, refresh of the skeletal records
#			and finally run the SAS overnight jobs for marketing.
#			Each will dependant on the previous job completing 
#			and different jobs will be run on different days of
#			week.
#
# Parameters:		1st	size of the sequence
#			2nd	starting number
#
# Author:		Anthony Firmin, FCCL
#
# Date Written:		3/12/01
#
# Change history:	
#			
#	
#
###################################################################################

# set -x

###################################################################################
##########################   FUNCTIONS   ##########################################
###################################################################################

usage() {

print "
UX: jan - just a number generator: ERROR: invalid syntax.
usage:  jan [size of sequence] [starting number]
"

}


###################################################################################
#######################   END OF FUNCTIONS   ######################################
###################################################################################

###################################################################################
##########################   MAIN CODE   ##########################################
###################################################################################

# set up the env... 

PATH=/usr/ccs/bin:/usr/bin:/usr/sbin:/usr/ucb:/etc:/usr/openwin/bin:.:/u01/app/oracle/product/8.1.7/bin:/usr/local/bin

if [[ $# -gt 2 ]]
then
	usage
	return 1
fi

if [[ $# -eq 2 ]]
then
	size=$1
	start=$2
fi

if [[ $# -eq 1 ]]
then
	size=$1
	start=1
fi


if [[ $# -eq 0 ]]
then
	size=10
	start=1
fi

counter=1
print $start

while [ $counter -lt $size ]
do
	let start=$start+1
	let counter=$counter+1
	print $start
done



###################################################################################
#######################   END OF MAIN CODE   ######################################
###################################################################################
