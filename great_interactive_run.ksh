#!/usr/bin/ksh
#
###################################################################################
#
# Name: 		great_interactive_run
#
# Description:		Script to run the backup, run the phase 1 and phase 2
#			database refreshes, refresh of the skeletal records
#			and finally run the SAS overnight jobs for marketing.
#			Each will dependant on the previous job completing 
#			and different jobs will be run on different days of
#			week.
#			This script is to be run from the UNIX command prompt
#			and not from cron.
#			There are two parameters to the script...
#				1.	day of the week (sun, mon, tue, etc.)
#				2.	whether the backup is to be run or not
#
#
# Author:		Anthony Firmin, FCCL
#
# Date Written:		14/11/01
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

backup () {

print "======================================================================="
print "GREAT_OVERNIGHT RUN start system backup" $(date)
print "======================================================================="

# Run the system backup...

/usr/local/bin/backup_system_nsr

print "======================================================================="
print "GREAT_OVERNIGHT RUN system backup complete" $(date)
print "======================================================================="

}

###################################################################################

refresh_p1 () {

print "======================================================================="
print "GREAT_OVERNIGHT RUN start phase 1 main database refresh" $(date)
print "======================================================================="

# Run the phase 1 main database refresh...

su - sdbadm -c "/u01/home/sdbadm/refresh/run_refresh_all.ksh"

print "======================================================================="
print "GREAT_OVERNIGHT RUN phase 1 main database refresh complete" $(date)
print "======================================================================="

}

###################################################################################

refresh_p2 () {

print "======================================================================="
print "GREAT_OVERNIGHT RUN start phase 2 main database refresh" $(date)
print "======================================================================="

day=$1

# Run the phase 2 main database refresh...

su - sdbadm -c "/u01/home/sdbadm/refresh/run_phase2_complete_$day.ksh"

print "======================================================================="
print "GREAT_OVERNIGHT RUN phase 2 main database refresh complete" $(date)
print "======================================================================="

}

###################################################################################

refresh_sample () {

print "======================================================================="
print "GREAT_OVERNIGHT RUN start sample database refresh" $(date)
print "======================================================================="

day=$1

# Run the sample database refresh...

su - sdbadm -c "/u01/home/sdbadm/refresh/run_refresh_sample_$day.ksh"

print "======================================================================="
print "GREAT_OVERNIGHT RUN sample database refresh complete" $(date)
print "======================================================================="

}

###################################################################################

marketing_scripts () {

print "======================================================================="
print "GREAT_OVERNIGHT RUN start run of SAS overnight and daily tasks" $(date)
print "======================================================================="

# Run the SAS jobs for each user...

for i in jonh robd adelel
do
	su - $i -c "sas_overnight.ksh > sas_overnight.log.$(date "+%y%m%d") 2>&1" &
	su - $i -c "sas_daily.ksh > sas_daily.log.$(date "+%y%m%d") 2>&1" &
done

print "======================================================================="
print "GREAT_OVERNIGHT RUN run of SAS overnight and daily tasks complete" $(date)
print "======================================================================="

}

###################################################################################

usage() {

print "
UX: great_interactive_run: ERROR: invalid syntax.
usage:  great_interactive_run	day-of-week [ backup ]
"

}

###################################################################################
#######################   END OF FUNCTIONS   ######################################
###################################################################################

###################################################################################
##########################   MAIN CODE   ##########################################
###################################################################################

print "======================================================================="
print "GREAT_OVERNIGHT RUN starting" $(date)
print "======================================================================="

# set up the env... 

PATH=/usr/ccs/bin:/usr/bin:/usr/sbin:/usr/ucb:/etc:/usr/openwin/bin:.:/u01/app/oracle/product/8.1.7/bin:/usr/local/bin

# validate number of parameters passed...

if [[ $# -lt 1 || $# -gt 2 ]]
then
	usage
	return 1
fi

# validate the day of the week...

typeset -l dow=$1

case $dow in
	mon|tue|wed|thu|fri|sat|sun)
		;;
	*)
		usage
		return 1
		;;
esac

# validate that the backup request is set as parameter 2...

if [[ $# -eq 2 ]]
then
	typeset -l run_backup=$2
	if [[ $run_backup = "backup" ]]
	then
		run_backup="y"
	else
		usage
		return 1
	fi
else
	run_backup="n"
fi

# Confirm that backup is or is not going to be run...

verify=0

until [[ $verify -eq 1 ]]
do
	if [[ $run_backup = "y" ]]
	then
		print "\nAre you sure you want to perform a backup now? [y/n] \c"
	else
		print "\nWould you like to perform a backup now? [y/n] \c"
	fi

	read ans

	case $ans in
		y|Y)
			run_backup="y"
			verify=1
			;;
		n|N)
			run_backup="n"
			verify=1
			;;
		*)
			print "Incorrect response, please enter y or n..."
			print ""
			;;
	esac
done
		
# depending on the day of the week will determine the processing to take place...

case $dow in

	sun)
		if [[ $run_backup = "y" ]]
		then
			backup
		fi
		refresh_p1
		marketing_scripts
		wait
		refresh_p2 $dow
		;;

	mon)
		if [[ $run_backup = "y" ]]
		then
			backup
		fi
		refresh_p1
		marketing_scripts
		;;

	tue)
		refresh_p1
		refresh_p2 $dow
		marketing_scripts
		;;

	wed)
		if [[ $run_backup = "y" ]]
		then
			backup
		fi
		marketing_scripts
		;;

	thu)
		if [[ $run_backup = "y" ]]
		then
			backup
		fi
		marketing_scripts
		;;

	fri)
		refresh_p1
		refresh_p2 $dow
		marketing_scripts
		;;

	sat)
		if [[ $run_backup = "y" ]]
		then
			backup
		fi
		refresh_sample $dow
		marketing_scripts
		;;

esac

#
# Wait for jobs to finish before exiting...
#

wait

print "======================================================================="
print "GREAT_OVERNIGHT_RUN All Jobs Complete" $(date)
print "======================================================================="

exit

###################################################################################
#######################   END OF MAIN CODE   ######################################
###################################################################################
