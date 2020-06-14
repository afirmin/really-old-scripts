#!/usr/bin/ksh 
#
# Name:		sas_daytime.ksh
#
# Author: 	Anthony Firmin, FCCL
#
# Date: 	17/8/01
#
# Description:	The SAS user has the option to ftp over a file from their 
#		PC to their home directory on the Unix Server which
#		they want to be run during the day.
#		The script checks to see if the script exists and if it does
#		it renames the file and then runs it as input to the sas executable.
#		After execution, the file emails the output to the user.
#		The file is renamed before the file is used as input. 
#	
# Change History:
#
#

PATH=/usr/ccs/bin:/usr/bin:/usr/sbin:/usr/ucb:/etc:/usr/openwin/bin:.
export PATH
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=/u01/app/oracle/product/8.1.7
ORACLE_SID=sasdb
TMPDIR=/tmp
LD_LIBRARY_PATH=$ORACLE_HOME/lib:/usr/lib
PATH=$PATH:$ORACLE_HOME/bin
export ORACLE_BASE ORACLE_HOME ORACLE_SID TMPDIR LD_LIBRARY_PATH PATH

# set -x

u_time=$(date "+%d.%m.%y:%H:%M")


case `whoami` in 
	root )
		user_name=afirmin
		mail_name=afirmin ;;
	afirmin )
		user_name=afirmin
		mail_name=afirmin ;;
esac

cd /export/home/$user_name

if [[ -f sas.day ]]
then
	mv sas.day sas.$u_time
 	./sas -sysin sas.$u_time
	print "Subject: SAS Daytime Run Log" $(print $u_time) > /tmp/sas.mail
	cat  sas.$u_time.log >> /tmp/sas.mail
	mail $mail_name@fccl.co.uk < /tmp/sas.mail
	if [ -f sas.$u_time.lst ]
	then
		print "Subject: SAS Daytime Output" $(print $u_time) > /tmp/sas.mail
		cat  sas.$u_time.lst >> /tmp/sas.mail
		mail $mail_name@fccl.co.uk < /tmp/sas.mail
	fi
	rm /tmp/sas.mail
fi


