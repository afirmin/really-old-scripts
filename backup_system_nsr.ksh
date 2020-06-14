#!/usr/bin/ksh
#
###################################################################################
#
# Name: 		backup_system_nsr
#
# Description:		Script to backup all mounted filesystems to 
#			the DLT tape device.
#
# Author:		Anthony Firmin, FCCL
#
# Date Written:		30/4/01
#
# Change history:	
#
# 21/4/01	A.Firmin
#	Added Oracle startup and shutdown functionality to the script
#
# 24/5/01	A.Firmin
#	Functionalised the calls to start and stop Oracle.
#	Added the functions to restart oracle after any tape failure messages
#	otherwise Oracle would reamin shut.
#
# 4/6/01	A.Firmin
#	Problem with shutdown immediate - it hung.  Consequently the functions
#	had to be moved to a seperate script (db_functions) which could be monitored 
#	for a hang, we check that the script has completed or after 5 mins the
#	script is killed and we call the script again with an abort parameter
#	to shutdown Oracle with an abort.  We then restart Oracle and shut it 
#	down again.  Backup then continues as before.  After backup is complete
#	we called db_functions again to restart Oracle.
#
# 8/6/01	A.Firmin
#	Created _nsr version from the backup_system script.
#	Removed the loop surrounding, and the call to, ufsdump and replaced it 
#	with a call to savefs for the backup within Legato Networker.
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
print "BACKUP_NSR Starting" $(date)
print "======================================================================="

# call timer, this estimates how long the backup will take...its quite accurate...

print ""
/usr/local/bin/timer
print ""

print "======================================================================="

# Call the function oracle_shut to shut down the database as the
# files need to be closed for a successful backup

db_functions immediate &

sleep 5

counter=0

while [ $counter -lt 30 ]
do
	if [[ $(ps -ef | grep db_function | grep -v grep | wc -l) -eq 0 ]]
	then
		break
	else
		let counter=$counter+1
		sleep 10
	fi
	if [[ $counter -eq 30 ]]
	then
		kill $(ps -ef | grep db_function | grep -v grep | awk '{print $2}')
		sleep 5
		if [[ $(ps -ef | grep db_function | grep -v grep | wc -l) -eq 1 ]]
		then
			kill -9 $(ps -ef | grep db_function | grep -v grep | awk '{print $2}') 
		fi
		db_functions abort 
		sleep 10
		db_functions start
		sleep 10
		db_functions immediate
	fi
done

print "BACKUP_NSR: Oracle shut down"
print "======================================================================="

# Having shutdown Oracle we can now call the Legato Networker command savefs
# to backup the system.  
#
# NOTE: If a new filesystem is added it needs to be added to the savegroup 
#       on the backup server.

print "======================================================================="
print "BACKUP_NSR: beginning network backup"
print "======================================================================="

remsh falmerg -l root "savegrp -G Zantos_Daily"

print "======================================================================="
print "BACKUP_NSR: network backup complete"
print "======================================================================="

mail	anthony@fccl.co.uk <<EOT
Subject: BACKUP_NSR - ZANTOS network backup complete
.
EOT

# Now call the function oracle_start to start up Oracle again...

db_functions start

print "======================================================================="
print "BACKUP_NSR: Oracle restarted"
print "======================================================================="
print "BACKUP_NSR Complete" $(date)
print "======================================================================="

exit
