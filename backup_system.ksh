#!/usr/bin/ksh
#
###################################################################################
#
# Name: 		backup_system
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
# 18/6/01	T.Barnsley
#	/u06 was filling up the tape and as it only contained the redo logs 
#	it can be ignored so has been omitted from the backup.
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
print "BACKUP Starting" $(date)
print "======================================================================="

# call timer, this estimates how long the backup will take...its quite accurate...
/usr/local/bin/timer

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

print "BACKUP: Oracle shut down"
print "======================================================================="

# This is a no rewind tape device with compression....

TAPE_DEVICE=/dev/nrst28

# Time to chack the status of the tape device...

mt -f $TAPE_DEVICE stat
ERR_CODE=$?

if [[ $ERR_CODE -ne 0 ]]
then
	print $TAPEDEVICE "Not online"
	print "Restarting Oracle"
	db_functions start
	print "Exiting..."
	return 1
fi

# Have checkedthe status of the tape its time to do the backup.
# This for loop calls ufsdump for each of the filesystems on the system
# and checks the status, if there is an error - report it and exit...

for MOUNT_POINT in $(df -k | egrep "vol|dsk/var" |grep -v u06 | awk '{print $6}' )
do

	print "======================================================================="
	print "BACKUP: dumping $MOUNT_POINT"
	print "======================================================================="
	ufsdump 0fu $TAPE_DEVICE $MOUNT_POINT
	ERR_CODE=$?
	
	if [[ $ERR_CODE -ne 0 ]]
	then
		print $TAPEDEVICE " error " $ERR_CODE
		print "Restarting Oracle"
		db_functions start
		print "Exiting..."
		return 1
	fi

	print "======================================================================="
	print "BACKUP: $MOUNT_POINT dump complete"
	print "======================================================================="

done

# Now rewind the tape...

mt -f $TAPE_DEVICE rew
ERR_CODE=$?

if [[ $ERR_CODE -ne 0 ]]
then
	print $TAPEDEVICE "Unable to rewind"
	print "Restarting Oracle"
	db_functions start
	print "Exiting..."
	return 1
fi

# As we have had success so far, the tape needs to come offline to
# avoid being overwritten.

mt -f $TAPE_DEVICE rewoffl
ERR_CODE=$?

if [[ $ERR_CODE -ne 0 ]]
then
	print $TAPEDEVICE "Unable to rewind offline"
	print "Restarting Oracle"
	db_functions start
	print "Exiting..."
	return 1
fi

# Now call the function oracle_start to start up Oracle again...

db_functions start

print "======================================================================="
print "BACKUP: Oracle restarted"
print "======================================================================="
print "BACKUP Complete" $(date)
print "======================================================================="

exit
