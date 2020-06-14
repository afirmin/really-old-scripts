#!/usr/bin/ksh
#
###################################################################################
#
# Name:                 run_stats
#
# Description:          This script is run from cron at 01:00 every Monday morning.
#			The script removes the old stat info files and makes 3
#			calls to sar_graph to generate cpu, memory and swap info.
#
# Parameters:           None.
#
#
#
# Author:               Anthony Firmin, FCCL
#
# Date Written:         27/8/02
#
# Change History:
#
#
#
###################################################################################

# set -x

###################################################################################
##########################   MAIN CODE   ##########################################
###################################################################################

# set up the env...

PATH=/usr/ccs/bin:/usr/bin:/usr/sbin:/usr/ucb:/etc:/usr/openwin/bin:.:/u01/app/oracle/product/8.1.7/bin:/usr/local/bin
mail_file=/tmp/mail_file.stats
server_name=Zantos

# Remove the old output files first...

cd /tmp

rm zantos_sar_*

# Set up header for the mailfile...

print "Subject: $server_name Stats Collection" > $mail_file

# Now call the sar_graph script to generate the stats...

sar_graph.ksh -c 1

if [[ $? -eq 0 ]]
then
	print "$server_name CPU stats collected successfully" >> $mail_file
else
	print "$server_name CPU stats collection FAILED" >> $mail_file
fi	

sar_graph.ksh -m 1

if [[ $? -eq 0 ]]
then
	print "$server_name Memory stats collected successfully" >> $mail_file
else
	print "$server_name Memory stats collection FAILED" >> $mail_file
fi	

sar_graph.ksh -s 1

if [[ $? -eq 0 ]]
then
	print "$server_name Swap stats collected successfully" >> $mail_file
else
	print "$server_name Swap stats collection FAILED" >> $mail_file
fi	

# Everything is completed so send out email...

mail    anthony@fccl.co.uk < $mail_file

