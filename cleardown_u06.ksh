#!/usr/bin/ksh
#
###################################################################################
#
# Name: 		cleardown_u06_nsr
#
# Description:		Script to delete archive logs over 1 day old.
#
#
# Author:		Anthony Firmin, FCCL
#
# Date Written:		5/7/02
#
# Change history:	
#
#
#
###################################################################################

# set -x

###################################################################################
##########################   MAIN CODE   ##########################################
###################################################################################

# set up the Oracle env... 

PATH=/usr/ccs/bin:/usr/bin:/usr/sbin:/usr/ucb:/etc:/usr/openwin/bin:.:/u01/app/oracle/product/8.1.7/bin:/usr/local/bin
ORACLE_BASE=/u01/app/oracle
ORACLE_SID=sasdb
ORACLE_DOC=/u01/app/oracle/doc
LD_LIBRARY_PATH=/lib:/usr/lib
ORACLE_HOME=/u01/app/oracle/product/8.1.7

print "======================================================================="
print "CLEARDOWN_U06 Starting" $(date)
print "======================================================================="
print "CLEARDOWN_U06: determining files for deletion"
print "======================================================================="


# Firstly determine the files to be deleted after the backup...

cd /u06/oradata/sasdb/arch

find . -mtime +0 -print > /tmp/arch_full.lst

tot_lines=$(cat /tmp/arch_full.lst | wc -l | sed -e "s/ //g")

print "CLEARDOWN_U06: deleting files from /u06/oradata/sasdb/arch"

if [[ $del_lines -gt 0 ]]
then
	for i in $(cat /tmp/arch_del.lst)
	do
		print "Deleting $i"
		rm $i
	done
fi

mail    anthony@fccl.co.uk <<EOT
Subject: CLEARDOWN_U06 - /u06 file deletion complete
.
EOT

print "======================================================================="
print "CLEARDOWN_U06 Complete" $(date)
print "======================================================================="

exit
