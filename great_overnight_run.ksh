#!/usr/bin/ksh
#
###################################################################################
#
# Name: 		great_overnight_run
#
# Description:		Script to run the backup, run the phase 1 and phase 2
#			database refreshes, refresh of the skeletal records
#			and finally run the SAS overnight jobs for marketing.
#			Each will dependant on the previous job completing 
#			and different jobs will be run on different days of
#			week.
#
# Author:		Anthony Firmin, FCCL
#
# Date Written:		26/9/01
#
# Change history:	
#			Anthony Firmin	9/11/01
#			Change in plan for scripts to be run.
#			Function refresh_p2 is now passed a parameter of the name
#			of the day which makes up the name fo the script to be run.
#			This is for Sunday, Tuesday and Friday.
#			The script name for p2 has also been changed to...
#				run_phase2_complete_xxx.ksh where xxx is dow!!!
#			On a Saturday the script to be run has been renamed...
#				run_refresh_sample_sat.ksh
#			The function refresh_skeletal has been removed.
# 
#			Anthony Firmin	12/11/01
#			Minor corrections to fix typo's.
#			Also gave all the log files a date suffix to enable 
#			monitoring of weekend jobs and to keep a history.
# 
#			Anthony Firmin	19/11/01
#			Added new function to deal with Monday morning marketing
#			script runs.  If Sundays overnights finish before midnight
#			it will run Sundays marketing scripts instead of Mondays.
#			Put in a delay so it will wait until Monday morning to run
#			them.
# 
#			Anthony Firmin	21/11/01
#			Added the sending of an email to let everyone know the script
#			has completed running.
#
#			Anthony Firmin	3/12/01
#			Removed the sleep in the function marketing_scripts_sun as 
#			it was causing issues.  Instead the sas_daily.ksh is passed 
#			the parameter "mon" so it knows which nights scripts to run.
#
#			Anthony Firmin	4/12/01
#			Added the check for Oracle errors after each of the refreshes.
#			If an error is detected, we do not progress and an email
#			is sent out.
#			This was previously in the sas_ensure_avail script.
#			TB advises that if there are Oracle errors returned from P1
#			then P2 should not be run.  Marketing scripts will still be
#			run.
#			
#			Anthony Firmin 6/12/01
#			Altered the running schedule again with assistance from TB.
#			Made each call to the function marketing_scripts pass a 
#			parameter of the day of the week.
#			
#			Anthony Firmin 11/12/01
#			Added the function refresh_static.  Called after run of p1.
#			Run in the background.
#			
#			Anthony Firmin 14/12/01
#			Added the function refresh_once.  This is to be used if 
#			there is a need for jobs to be run as a one time deal, i.e.
#			updating the mailer_account_flagging table.
#			Also added new function backup_u06_nsr which backups up
#			all the archive redo logs in /u06.	
#			
#			Anthony Firmin 8/1/02
#			If there is a problem that delays the start of the backup
#			we don't want it starting after 01:00 as it is currently 
#			taking over 6 hours and we need it to be available after
#			07:00.  This change was made to the backup() function.
#			
#			Anthony Firmin 10/1/02
#			In the refresh_p2 and refresh_sample functions additional
#			calls to run_error_exceptions_mkt.ksh and 
#			run_error_exceptions_sample.ksh are made and the relevant 
#			log file is checked for error messages.
#			
#			Anthony Firmin 12/2/02
#			The order of battle has changed slightly.  Running the 
#			refresh_p2 function is now dependant on p1 completing 
#			successfully, refresh_static is still run irregardless.
#			
#			Anthony Firmin 26/2/02
#			Added a "sleep 60" after the backup to ensure Oracle has
#			fully restarted before continuing.
#			
#			Anthony Firmin 27/5/02
#			Problem with the backup skpping if it starts after 1am on
#			a Sunday morning.  Test changed to check if it is not a 
#			Sunday.
#			
#			Anthony Firmin 27/5/02
#			Changed the backup of u06.  Changed the name of the function
#			backup_u06 to backup_u06_old and created a new backup_u06.
#			The new function copies files over 0 days old to /tts/u06_arch
#			and the files in there which are over 4 days old are removed.
#
#			Anthony Firmin 7/11/02
#			In order to meet the requirements of the key milestones, of 
#			which the running of this script is a part, the messages are
#			output to a sperate file by use of the tee command and this
#			log file is emailed seperately to the operators as well as 
#			selected individuals!!!
#
#
#
###################################################################################

# set -x

###################################################################################
##########################   FUNCTIONS   ##########################################
###################################################################################

backup () {

print "=======================================================================" | tee -a $SLA_MAIL_FILE
print "GREAT_OVERNIGHT RUN start system backup" $(date) | tee -a $SLA_MAIL_FILE
print "=======================================================================" | tee -a $SLA_MAIL_FILE

# Run the system backup...

hour=$(date "+%H")
day=$(date "+%a")

# if [[ $hour -gt 1 && $hour -lt 17 ]]
if [[ $hour -gt 1 && $hour -lt 17 && $day != "Sun" ]]
then
        print "" | tee -a $SLA_MAIL_FILE
        print "*** As the start of the backup is after 01:00 on a weekday backup is being skipped ***" | tee -a $SLA_MAIL_FILE
        print "" | tee -a $SLA_MAIL_FILE
else
	/usr/local/bin/backup_system_nsr
fi

# There has been an issue with Oracle not having started properly when the
# next step kicks in.  So we sleep for 60 secs before continuing...

sleep 60

print "=======================================================================" | tee -a $SLA_MAIL_FILE
print "GREAT_OVERNIGHT RUN system backup complete" $(date) | tee -a $SLA_MAIL_FILE
print "=======================================================================" | tee -a $SLA_MAIL_FILE

}

###################################################################################

backup_u06 () {

print "=======================================================================" | tee -a $SLA_MAIL_FILE
print "GREAT_OVERNIGHT RUN start backup_u06 to /tts/u06_arch" $(date) | tee -a $SLA_MAIL_FILE
print "=======================================================================" | tee -a $SLA_MAIL_FILE

# Move the files out of /u06...

# cd /u06/oradata/sasdb/arch

# for arch_file in $(find . -atime 0 -print)
# do
        # if [[ $arch_file = [.] ]]
        # then
                # :
        # else
                # mv $arch_file /tts/u06_arch
        # fi
# done

# And now delete files in this area that are older than 4 days...

find /u06/oradata/sasdb/arch -atime +2 -exec rm -f {} \;

print "=======================================================================" | tee -a $SLA_MAIL_FILE
print "GREAT_OVERNIGHT RUN backup_u06 to /tts/u06_arch complete" $(date) | tee -a $SLA_MAIL_FILE
print "=======================================================================" | tee -a $SLA_MAIL_FILE

}

###################################################################################

backup_u06_old () {

print "=======================================================================" | tee -a $SLA_MAIL_FILE
print "GREAT_OVERNIGHT RUN start backup_u06" $(date) | tee -a $SLA_MAIL_FILE
print "=======================================================================" | tee -a $SLA_MAIL_FILE

# Run the backup of /u06...

/usr/local/bin/backup_u06_nsr

print "=======================================================================" | tee -a $SLA_MAIL_FILE
print "GREAT_OVERNIGHT RUN backup_u06 complete" $(date) | tee -a $SLA_MAIL_FILE
print "=======================================================================" | tee -a $SLA_MAIL_FILE

}

###################################################################################

refresh_p1 () {

print "=======================================================================" | tee -a $SLA_MAIL_FILE
print "GREAT_OVERNIGHT RUN start phase 1 main database refresh" $(date) | tee -a $SLA_MAIL_FILE
print "=======================================================================" | tee -a $SLA_MAIL_FILE

# Run the phase 1 main database refresh...

su - sdbadm -c "/u01/home/sdbadm/refresh/run_refresh_all.ksh"

# check for errors in the log file, if found email them...

cd /u01/home/sdbadm/logs

log_file=/u01/home/sdbadm/logs/$(ls -rt refresh_all.log.* | tail -1)

if grep -h ORA $log_file > /dev/null 2>&1
then
	refresh_errors $log_file
	print "=======================================================================" | tee -a $SLA_MAIL_FILE
	print "GREAT_OVERNIGHT RUN phase 1 ERRORS " $(date) | tee -a $SLA_MAIL_FILE
	print "=======================================================================" | tee -a $SLA_MAIL_FILE
	return 1
fi

print "=======================================================================" | tee -a $SLA_MAIL_FILE
print "GREAT_OVERNIGHT RUN phase 1 main database refresh complete" $(date) | tee -a $SLA_MAIL_FILE
print "=======================================================================" | tee -a $SLA_MAIL_FILE

}

###################################################################################

refresh_static () {

print "=======================================================================" | tee -a $SLA_MAIL_FILE
print "GREAT_OVERNIGHT RUN start static main database refresh" $(date) | tee -a $SLA_MAIL_FILE
print "=======================================================================" | tee -a $SLA_MAIL_FILE

# Run the static main database refresh...

su - sdbadm -c "/u01/home/sdbadm/refresh/run_refresh_static.ksh"

# check for errors in the log file, if found email them...

cd /u01/home/sdbadm/logs

log_file=/u01/home/sdbadm/logs/$(ls -rt refresh_static.log.* | tail -1)

if grep -h ORA $log_file > /dev/null 2>&1
then
	refresh_errors $log_file
	print "=======================================================================" | tee -a $SLA_MAIL_FILE
	print "GREAT_OVERNIGHT RUN static ERRORS " $(date) | tee -a $SLA_MAIL_FILE
	print "=======================================================================" | tee -a $SLA_MAIL_FILE
	return 1
fi

print "=======================================================================" | tee -a $SLA_MAIL_FILE
print "GREAT_OVERNIGHT RUN static main database refresh complete" $(date) | tee -a $SLA_MAIL_FILE
print "=======================================================================" | tee -a $SLA_MAIL_FILE

}

###################################################################################

refresh_p2 () {

print "=======================================================================" | tee -a $SLA_MAIL_FILE
print "GREAT_OVERNIGHT RUN start phase 2 main database refresh" $(date) | tee -a $SLA_MAIL_FILE
print "=======================================================================" | tee -a $SLA_MAIL_FILE

day=$1

# Run the phase 2 main database refresh...

su - sdbadm -c "/u01/home/sdbadm/refresh/run_phase2_complete_$day.ksh"

# check for errors in the log file, if found email them...

cd /u01/home/sdbadm/logs

log_file=/u01/home/sdbadm/logs/$(ls -rt phase2_complete_*.log.* | tail -1)

if grep -h ORA $log_file > /dev/null 2>&1
then
	refresh_errors $log_file
	print "=======================================================================" | tee -a $SLA_MAIL_FILE
	print "GREAT_OVERNIGHT RUN phase 2 ERRORS " $(date) | tee -a $SLA_MAIL_FILE
	print "=======================================================================" | tee -a $SLA_MAIL_FILE
	return 1
fi

# run the check load script...

su - sdbadm -c "/u01/home/sdbadm/refresh/run_check_load.ksh"

# check the check_base_load log for errors...

cd /u01/home/sdbadm/logs

check_logfile=/u01/home/sdbadm/logs/$(ls -rt check_base_load.log.* | tail -1)

check_val=$(cat $check_logfile | tail -1)

if [[ $check_val -gt 0 ]]
then
	print "Subject: Check Load Errors" > /tmp/check_mail.file
	cat $check_logfile >> /tmp/check_mail.file
	mail $MAILING_LIST < /tmp/check_mail.file
fi

# now run the error exceptions script...

su - sdbadm -c "/u01/home/sdbadm/refresh/run_error_exceptions.ksh"

# check the execptions error log for messages..

error_logfile=/u01/home/sdbadm/logs/$(ls -rt error_exceptions_mkt.log.* | tail -1)

if grep "no rows selected" $error_logfile > /dev/null 2>&1
then
	:
else
	refresh_errors $error_logfile
	print "=======================================================================" | tee -a $SLA_MAIL_FILE
	print "GREAT_OVERNIGHT RUN phase 2 EXCEPTIONS " $(date) | tee -a $SLA_MAIL_FILE
	print "=======================================================================" | tee -a $SLA_MAIL_FILE
	return 1
fi

print "=======================================================================" | tee -a $SLA_MAIL_FILE
print "GREAT_OVERNIGHT RUN phase 2 main database refresh complete" $(date) | tee -a $SLA_MAIL_FILE
print "=======================================================================" | tee -a $SLA_MAIL_FILE

}

###################################################################################

refresh_sample () {

print "=======================================================================" | tee -a $SLA_MAIL_FILE
print "GREAT_OVERNIGHT RUN start sample database refresh" $(date) | tee -a $SLA_MAIL_FILE
print "=======================================================================" | tee -a $SLA_MAIL_FILE

day=$1

# Run the sample database refresh...

su - sdbadm -c "/u01/home/sdbadm/refresh/run_refresh_sample_$day.ksh"

# check for errors in the log file, if found email them...

cd /u01/home/sdbadm/logs

log_file=/u01/home/sdbadm/logs/$(ls -rt refresh_sample_*.log.* | tail -1)

if grep -h ORA $log_file > /dev/null 2>&1
then
	refresh_errors $log_file
	print "=======================================================================" | tee -a $SLA_MAIL_FILE
	print "GREAT_OVERNIGHT RUN sample ERRORS " $(date) | tee -a $SLA_MAIL_FILE
	print "=======================================================================" | tee -a $SLA_MAIL_FILE
	return 1
fi

# now run the error exceptions script...

su - sdbadm -c "/u01/home/sdbadm/refresh/run_error_exceptions_sample.ksh"

# check the execptions error log for messages..

error_logfile=/u01/home/sdbadm/logs/$(ls -rt error_exceptions_sample.log.* | tail -1)

if grep "no rows selected" $error_logfile > /dev/null 2>&1
then
	:
else
	refresh_errors $error_logfile
	print "=======================================================================" | tee -a $SLA_MAIL_FILE
	print "GREAT_OVERNIGHT RUN sample EXCEPTIONS " $(date) | tee -a $SLA_MAIL_FILE
	print "=======================================================================" | tee -a $SLA_MAIL_FILE
	return 1
fi

print "=======================================================================" | tee -a $SLA_MAIL_FILE
print "GREAT_OVERNIGHT RUN sample database refresh complete" $(date) | tee -a $SLA_MAIL_FILE
print "=======================================================================" | tee -a $SLA_MAIL_FILE

}

##################################################################################

refresh_once () {

print "=======================================================================" | tee -a $SLA_MAIL_FILE
print "GREAT_OVERNIGHT RUN start once database refresh" $(date) | tee -a $SLA_MAIL_FILE
print "=======================================================================" | tee -a $SLA_MAIL_FILE

# Run the once main database refresh...

su - sdbadm -c "/u01/home/sdbadm/refresh/run_refresh_once.ksh"

# check for errors in the log file, if found email them...

cd /u01/home/sdbadm/logs

log_file=/u01/home/sdbadm/logs/$(ls -rt refresh_once.log.* | tail -1)

if grep -h ORA $log_file > /dev/null 2>&1
then
	refresh_errors $log_file
	print "=======================================================================" | tee -a $SLA_MAIL_FILE
	print "GREAT_OVERNIGHT RUN once ERRORS " $(date) | tee -a $SLA_MAIL_FILE
	print "=======================================================================" | tee -a $SLA_MAIL_FILE
	return 1
fi

print "=======================================================================" | tee -a $SLA_MAIL_FILE
print "GREAT_OVERNIGHT RUN once database refresh complete" $(date) | tee -a $SLA_MAIL_FILE
print "=======================================================================" | tee -a $SLA_MAIL_FILE

}

###################################################################################

refresh_errors () {

REFRESH_FILE=$1
print "Subject: ZANTOS - REFRESH ERRORS "        > $MAIL_FILE
print "" >> $MAIL_FILE 
print "SAS_AVAILABLILITY: REFRESH ERRORS $REFRESH_FILE" >> $MAIL_FILE
print "" >> $MAIL_FILE
print "              REFRESH MAY NOT HAVE COMPLETED SUCCESSFULLY" >> $MAIL_FILE
print "" >> $MAIL_FILE
print "=======================================================================" >> $MAIL_FILE
print "" >> $MAIL_FILE 
cat $REFRESH_FILE >> $MAIL_FILE
print "." >> $MAIL_FILE

mail $MAILING_LIST < $MAIL_FILE

}

###################################################################################

marketing_scripts () {

print "=======================================================================" | tee -a $SLA_MAIL_FILE
print "GREAT_OVERNIGHT RUN start run of SAS overnight and daily tasks" $(date) | tee -a $SLA_MAIL_FILE
print "=======================================================================" | tee -a $SLA_MAIL_FILE

# get the day to be run from the parameter passed...

day=$1

# Run the SAS jobs for each user...

for i in jonh robd adelel 
do
	su - $i -c "sas_overnight.ksh > sas_overnight.log.$(date "+%y%m%d") 2>&1"
	su - $i -c "sas_daily.ksh $day > sas_daily.log.$(date "+%y%m%d") 2>&1"
done

print "=======================================================================" | tee -a $SLA_MAIL_FILE
print "GREAT_OVERNIGHT RUN run of SAS overnight and daily tasks complete" $(date) | tee -a $SLA_MAIL_FILE
print "=======================================================================" | tee -a $SLA_MAIL_FILE

}

###################################################################################

sla_email () {

print "=======================================================================" >> $SLA_MAIL_FILE
print "GREAT_OVERNIGHT RUN end of refreshes" $(date) >> $SLA_MAIL_FILE
print "=======================================================================" >> $SLA_MAIL_FILE

# send an email to show the SLA has been met (or not) !!!!

mail $SLA_MAILING_LIST < $SLA_MAIL_FILE

}

###################################################################################
#######################   END OF FUNCTIONS   ######################################
###################################################################################

###################################################################################
##########################   MAIN CODE   ##########################################
###################################################################################

print "=======================================================================" | tee -a $SLA_MAIL_FILE
print "GREAT_OVERNIGHT RUN starting" $(date) | tee -a $SLA_MAIL_FILE
print "=======================================================================" | tee -a $SLA_MAIL_FILE

# set up the env... 

PATH=/usr/ccs/bin:/usr/bin:/usr/sbin:/usr/ucb:/etc:/usr/openwin/bin:.:/u01/app/oracle/product/8.1.7/bin:/usr/local/bin

SLA_MAILING_LIST="anthony@fccl.co.uk"

SLA_MAIL_FILE=/tmp/g_o_r_km_file

> $SLA_MAIL_FILE
print "Subject: ZANTOS SLA Reporting"   > $SLA_MAIL_FILE

MAILING_LIST="anthony@fccl.co.uk"

MAIL_FILE=/tmp/g_o_r_mail_file

# determine the day of the week...

dow=$(date "+%a")
typeset -l dow=$dow

#
# the day of the week will determine the processing to take place.
# 
# the call to marketing_scripts is followed by the day of the week,
# this is different to the day of the week the script is started on 
# because it is the users perception of when it is run and that is
# also the suffix to the file to be run!!!
#

case $dow in

	sun)
		backup_u06
		refresh_p1
		if [[ $? -eq 0 ]]
		then
			refresh_p2 $dow
		else
			:
		fi
		refresh_static 
		sla_email
		marketing_scripts mon
		;;

	mon)
		backup_u06
		sla_email
		marketing_scripts tue
		;;

	tue)
		backup_u06
		refresh_p1
		if [[ $? -eq 0 ]]
		then
			refresh_p2 $dow
		else
			:
		fi
		refresh_static
		sla_email
		marketing_scripts wed 
		;;

	wed)
		backup_u06
		sla_email
		marketing_scripts thu
		;;

	thu)
		backup_u06
		sla_email
		marketing_scripts fri
		;;

	fri)
		backup_u06
		refresh_p1
		if [[ $? -eq 0 ]]
		then
			refresh_p2 $dow
		else
			:
		fi
		refresh_static
		sla_email
		marketing_scripts sat
		;;

	sat)
		backup_u06
		refresh_sample $dow
		sla_email
		marketing_scripts sun
		;;

esac

#
# Wait for jobs to finish before exiting...
#

wait

print "=======================================================================" 
print "GREAT_OVERNIGHT_RUN All Jobs Complete" $(date)
print "=======================================================================" 

#
# Now send out an email to relevant people to let them know it has all finished...
#

print "Subject: ZANTOS Overnight Run Completed"   > $MAIL_FILE

mail    $MAILING_LIST   	                < $MAIL_FILE


exit

###################################################################################
#######################   END OF MAIN CODE   ######################################
###################################################################################
