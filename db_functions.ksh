#!/usr/bin/ksh
#
###################################################################################
#
# Name: 		db_functions
#
# Description:		Script to shutdown, abort and restart an Oracle instance
#			dependant on parameter passed in !!!
#			This is designed to replace dbshut and dbstart as they
#			don't currently work.
#
# Author:		Anthony Firmin, FCCL
#
# Date Written:		4/6/01
#
# Change history:	
#
#			Anthony Firmin 21/1/02
#			Added the export of the ORACLE_SID within the function
#			so it is set remotely.
#
#			Anthony Firmin 7/2/02
#			Added the functions lsnr_stop and lsnr_start to stop and
#			start the listener.
#
#
#
###################################################################################

# set -x

###################################################################################
##########################   FUNCTIONS   ##########################################
###################################################################################

oracle_shut() {

su - oracle -c "export ORACLE_SID=sasdb;
svrmgrl <<EOF
connect internal
shutdown 
EOF
"

}

oracle_immediate() {

su - oracle -c "export ORACLE_SID=sasdb;
svrmgrl <<EOF
connect internal
shutdown immediate
EOF
"

}

oracle_abort() {

su - oracle -c "export ORACLE_SID=sasdb;
svrmgrl <<EOF
connect internal
shutdown abort
EOF
"

}

oracle_start() {

su - oracle -c "export ORACLE_SID=sasdb;
svrmgrl <<EOF
connect internal
startup
EOF
"

}

lsnr_stop() {

su - oracle -c "export ORACLE_SID=sasdb;
lsnrctl stop
"

}

lsnr_start() {

su - oracle -c "export ORACLE_SID=sasdb;
lsnrctl start
"

}


###################################################################################
##########################   MAIN CODE   ##########################################
###################################################################################

# set up the Oracle env... 

PATH=/usr/ccs/bin:/usr/bin:/usr/sbin:/usr/ucb:/etc:/usr/openwin/bin:.:/u01/app/oracle/product/8.1.7/bin
ORACLE_BASE=/u01/app/oracle
ORACLE_SID=sasdb
ORACLE_DOC=/u01/app/oracle/doc
LD_LIBRARY_PATH=/lib:/usr/lib
ORACLE_HOME=/u01/app/oracle/product/8.1.7

if [[ $1 == "shut" ]]
then
	oracle_shut
	return 0
fi

if [[ $1 == "abort" ]]
then
	oracle_abort
	return 0
fi

if [[ $1 == "start" ]]
then
	oracle_start
	return 0
fi

if [[ $1 == "immediate" ]]
then
	oracle_immediate
	return 0
fi

if [[ $1 == "lsnr_stop" ]]
then
	lsnr_stop
	return 0
fi

if [[ $1 == "lsnr_start" ]]
then
	lsnr_start
	return 0
fi
