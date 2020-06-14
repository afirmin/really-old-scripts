#!/usr/bin/ksh

# set up the env... 

set -x

PATH=/usr/ccs/bin:/usr/bin:/usr/sbin:/usr/ucb:/etc:/usr/openwin/bin:.:/u01/app/oracle/product/8.1.7/bin:/usr/local/bin


print "======================================================================="
print "SAS_MONDAY RUN start run of SAS overnight and daily tasks" $(date)
print "======================================================================="

# Run the SAS jobs for each user...

su - xxxxxx -c "sas_monday.ksh > sas_monday.log 2>&1" 

print "======================================================================="
print "SAS_MONDAY RUN run complete of SAS overnight and daily tasks" $(date)
print "======================================================================="

exit

