#!/usr/bin/ksh
#
###################################################################################
#
# Name: 		sas_ensure_avail
#
# Description:		Script to ensure SAS and Oracle are available at 7am
#
# Author:		Anthony Firmin, FCCL
#
# Date Written:		31/7/01
#
# Change history:	
#			3/9/01	Anthony Firmin
#			Substantial changes.  Functionalised the script.
#			Add functions to check if refresh is running and to
#			check for Oracle errors in the event of problems with the
#			refresh.  If there are problems send out an email.			
#
#			31/10/01	Anthony Firmin
#			Minor changes to fix problems with the incorrect info
#			being output in the email.			
#
#			4/12/01	Anthony Firmin
#			Removed the checks for Oracle errors and moved them
#			to the great_overnight_run script.
#
#			7/3/02	Anthony Firmin
#			Changed the search for backup pids to include "remsh falmerg"
#			and "save -s".
#
#
#
###################################################################################

# set -x

###################################################################################
##########################   VARIABLES   ##########################################
###################################################################################

# set up the Oracle env... 

PATH="/usr/ccs/bin:/usr/bin:/usr/sbin:/usr/ucb:/etc:/usr/openwin/bin:.:\
     /u01/app/oracle/product/8.1.7/bin:/usr/local/bin"
ORACLE_BASE=/u01/app/oracle
ORACLE_SID=sasdb
ORACLE_DOC=/u01/app/oracle/doc
LD_LIBRARY_PATH=/lib:/usr/lib
ORACLE_HOME=/u01/app/oracle/product/8.1.7

# Set up the mailing list - for those who need to know !!!

MAILING_LIST="anthony@fccl.co.uk"

MAIL_FILE=/tmp/s_e_a_mail_file

# Other variables...

###################################################################################
##########################   END VARIABLES   ######################################
###################################################################################

###################################################################################
##########################   FUNCTIONS   ##########################################
###################################################################################

stop_backup () {

# Kill off the backup processes...

for i in $(cat /tmp/backup_system_nsr.pids)
do
        print "Killing process " $i
        kill -9 $i
done

# Add to info in email...

print "=======================================================================" >> $MAIL_FILE
print "SAS_AVAILABLILITY: Backup Killed" >> $MAIL_FILE
print "=======================================================================" >> $MAIL_FILE

}

##################################################################################

start_oracle () {

print "Oracle not running at " $(date "+%H:%M:%S") >> $MAIL_FILE
print "" >> $MAIL_FILE 

db_functions start

sleep 30

print "=======================================================================" >> $MAIL_FILE
print "SAS_AVAILABLILITY: SAS / Oracle restarted at " $(date "+%H:%M:%S") >> $MAIL_FILE
print "=======================================================================" >> $MAIL_FILE
print "" >> $MAIL_FILE 
print "Overnight scripts (refresh and extracts) MAY NOT have run" >> MAIL_FILE
print "." >> MAIL_FILE

mail $MAILING_LIST < $MAIL_FILE

}

##################################################################################

refresh_running () {

print "" >> $MAIL_FILE 
print "=======================================================================" >> $MAIL_FILE
print "SAS_AVAILABLILITY: REFRESH STILL RUNNING at " $(date "+%H:%M:%S") >> $MAIL_FILE
print "=======================================================================" >> $MAIL_FILE
print "" >> $MAIL_FILE 
print "." >> MAIL_FILE

mail $MAILING_LIST < $MAIL_FILE

}

###################################################################################
##########################   END FUNCTIONS   ######################################
###################################################################################


###################################################################################
##########################   MAIN CODE   ##########################################
###################################################################################

print "Subject: SAS_AVAILABLILITY" > $MAIL_FILE 
print "=======================================================================" >> $MAIL_FILE
print "sas_ensure_available Starting" $(date "+%H:%M:%S") >> $MAIL_FILE
print "=======================================================================" >> $MAIL_FILE

# Determine how many backup_system_nsr processes are running and output the 
# pids to a file...

no_of_pids=$(ps -ef | egrep "backup_system_nsr|remsh falmerg|save -s" | grep -v grep | awk '{print $2}' > /tmp/backup_system_nsr.pids 2>&1;cat /tmp/backup_system_nsr.pids | wc -l);

# if the number of pids is > 0 then need to kill them off...

if [[ $no_of_pids -gt 0 ]]
then
	# so call function to stop backup...

	stop_backup

fi

# Check that Oracle is running. If it is not running start it...

if ! ps -ef | grep ora | grep pmon > /dev/null 2>&1
then

	start_oracle
	
	# By definition if we have probably had to kill off the backups and
	# had to start up the database engine then the refreshes won't have
	# worked so lets exit here while we still stand a fighting chance...

	exit

fi

# The story so far, the backup has completed and Oracle is up and running.
# Now lets see if the refresh is still running...

if ps -ef | grep refresh | grep -v grep > /dev/null 2>&1
then

	# the refresh is still running so call the function to add text
	# to let the user know the refresh is still running, send the
	# email and exit...

	refresh_running

	exit

fi


###################################################################################
########################## END MAIN CODE   ########################################
###################################################################################
