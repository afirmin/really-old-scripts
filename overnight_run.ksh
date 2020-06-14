#!/usr/bin/ksh
#
###################################################################################
#
# Name: 		overnight_run
#
# Description:		Script to run the backup, run the database refresh
#			and finally run the SAS overnight jobs.
#
# Author:		Anthony Firmin, FCCL
#
# Date Written:		25/9/01
#
# Change history:	
#
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

print "======================================================================="
print "OVERNIGHT RUN starting" $(date)
print "======================================================================="


print "======================================================================="
print "OVERNIGHT RUN start backup" $(date)
print "======================================================================="

# Call the backup process...

backup_system_nsr

print "======================================================================="
print "OVERNIGHT RUN backup complete" $(date)
print "======================================================================="

print "======================================================================="
print "OVERNIGHT RUN start database refresh" $(date)
print "======================================================================="

# Run the main database refresh - not run in the background...

su - sdbadm -c "/u01/home/sdbadm/refresh/run_refresh_all.ksh > /dev/null 2>&1"

print "======================================================================="
print "OVERNIGHT RUN database refresh complete" $(date)
print "======================================================================="

# The refresh of the sample database can be run in the background as the SAS
# overnights will be run against the marketing and not the sample database.

su - sdbadm -c "/u01/home/sdbadm/refresh/run_refresh_sample.ksh > /dev/null 2>&1" &

print "======================================================================="
print "OVERNIGHT RUN start run of SAS overnight and daily tasks" $(date)
print "======================================================================="

# Run the SAS jobs for each user...

for i in jonh robd adelel
do
	su - $i -c "sas_overnight.ksh > sas_overnight.log 2>&1" &
	su - $i -c "sas_daily.ksh > sas_daily.log 2>&1" &
done

print "======================================================================="
print "OVERNIGHT RUN run of SAS overnight and daily tasks complete" $(date)
print "======================================================================="

# Wait for all the jobs started in the background to complete and then exit...

wait

print "======================================================================="
print "OVERNIGHT_RUN Complete" $(date)
print "======================================================================="

exit
