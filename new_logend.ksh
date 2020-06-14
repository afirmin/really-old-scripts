#!/usr/bin/ksh

# set -x

today=$(date "+%d.%m.%y")
myuser=$(whoami)
cd /export/home/$myuser > /dev/null 2>&1

if [[ $? -ne 0 ]]
then
	print ""
	print "Error accessing directory for user: "$myuser
	print "Exiting..."
	print ""
	exit 1
fi

if [[ $# -eq 0 ]]
then
  if ls -atr sas.*$today*.log > /dev/null 2>&1
  then
	tail -25f $(ls -atr sas.*$today*.log | tail -1)
	exit 0
  else
	print "\nNo log files to display \n"
	exit 2
  fi
fi

#
#
#

if logname=$(ps -ef | grep $1 | grep sysin | grep -v grep | awk '{print $10}')
then
        logname=$logname.log
        if [[ $logname = ".log" ]]
        then
		print ""
		print "Unable to access log file for process: " $1
		print "Exiting..."
		print ""
		exit 3
        fi
        tail -f $logname
	exit 0
else
	print ""
	print "Failure to determine the log file name"
	print "Exiting..."
	print ""
	exit 4
fi

