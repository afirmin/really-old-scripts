#!/usr/bin/ksh 
#
# Name:		sas_overnight.ksh
#
# Author: 	Anthony Firmin, FCCL
#
# Date: 	2/7/01
#
# Description:	The SAS user has the option every day to ftp over a file
#		from their PC to their home directory on the Unix Server.
#		The script checks to see if the script exists and if it does
#		runs the file as input to the sas executable.
#		After execution, the file emails the output to the user and
#		renames the code file so if another file is not copied over
#		the job is not rerun the following evening.
#	
# Change History:
#
#

# set -x

PATH=/usr/ccs/bin:/usr/bin:/usr/sbin:/usr/ucb:/etc:/usr/openwin/bin:.
export PATH
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=/u01/app/oracle/product/8.1.7
ORACLE_SID=sasdb
TMPDIR=/tmp
LD_LIBRARY_PATH=$ORACLE_HOME/lib:/usr/lib
PATH=$PATH:$ORACLE_HOME/bin
export ORACLE_BASE ORACLE_HOME ORACLE_SID TMPDIR LD_LIBRARY_PATH PATH

case `whoami` in 
	root )
		user_name=afirmin
		mail_name=afirmin ;;
	afirmin )
		user_name=afirmin
		mail_name=afirmin ;;
esac

cd /export/home/$user_name

if [ -f sas.file ]
then
 	./sas -sysin sas.file
	mail $mail_name@fccl.co.uk < sas.file.log
	if [ -f sas.file.lst ]
	then
		mail $mail_name@fccl.co.uk < sas.file.lst
 		mv sas.file.lst sas.file.lst.`date "+%d%m%y"`
	fi
 	mv sas.file sas.file.`date "+%d%m%y"`
fi

