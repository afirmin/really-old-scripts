#!/usr/bin/ksh
#
###################################################################################
#
# Name: 		cleardown_u06
#
# Description:		Script to delete archive logs over a day old.
#
#
# Author:		Anthony Firmin, FCCL
#
# Date Written:		14/12/01
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

# Firstly determine the files to be deleted after the backup...

cd /u06/oradata/sasdb/arch

ls > /tmp/arch_full.lst

tot_lines=$(cat /tmp/arch_full.lst | wc -l | sed -e "s/ //g")

if [[ $tot_lines -gt 3 ]]
then
        let del_lines=$tot_lines-3
        cat /tmp/arch_full.lst | head -$del_lines > /tmp/arch_del.lst
else
	cat /dev/null > /tmp/arch_del.lst
	del_lines=0
fi


# print "======================================================================="
# print "CLEARDOWN_U06: beginning network backup"
# print "======================================================================="

# remsh falmerg -l root "savegrp -G Zantos_u06"

# print "======================================================================="
# print "CLEARDOWN_U06: network backup complete"
# print "======================================================================="

print "CLEARDOWN_U06: deleting files from /u06/oradata/sasdb/arch"

if [[ $del_lines -gt 0 ]]
then
	for i in $(cat /tmp/arch_del.lst)
	do
		print "Deleting $i"
		rm $i
	done
fi

# List files remaining in the directory...

print "======================================================================="
print "CLEARDOWN_U06 files remaining" $(date)
print "======================================================================="

ls -al /u06/oradata/sasdb/arch | sed -e "1,3 d"

mail    anthony@fccl.co.uk <<EOT
Subject: CLEARDOWN_U06 - backup and /u06 file deletion complete
.
EOT

print "======================================================================="
print "CLEARDOWN_U06 Complete" $(date)
print "======================================================================="

exit
