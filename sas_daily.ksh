#!/usr/bin/ksh 
#
# Name:		sas_daily.ksh
#
# Author: 	Anthony Firmin, FCCL
#
# Date: 	13/7/01
#
# Description:	The SAS user has the option to ftp over a file from their 
#		PC to their home directory on the Unix Server which
#		they want to be run daily.
#		The script checks to see if the script exists and if it does
#		runs the file as input to the sas executable.
#		After execution, the file emails the output to the user.
#		The file is not renamed as the code file will need to be rerun
#		the following week.
#	
# Change History:
#
#		4/12/01, Anthony Firmin
#		Added a line so that if there is a day parameter passed, it
#		is used.  Helps with the re-running of the script in case of
#		failure.
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

if [[ $# -eq 0 ]]
then
	u_dow=$(date "+%a")
	typeset -l dow=$u_dow
else
	typeset -l dow=$1
fi

case `whoami` in 
	root )
		user_name=afirmin
		mail_name=afirmin ;;
	afirmin )
		user_name=afirmin
		mail_name=afirmin ;;
esac

cd /export/home/$user_name

if [[ -f sas.$dow ]]
then
 	./sas -sysin sas.$dow
	mail $mail_name@fccl.co.uk < sas.$dow.log
	if [ -f sas.$dow.lst ]
	then
		mail $mail_name@fccl.co.uk < sas.$dow.lst
	fi
fi
