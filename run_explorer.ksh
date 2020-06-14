#!/usr/bin/ksh
#
###################################################################################
#
# Name: 		run_explorer.ksh
#
# Description:		Script to run the Sun Explorer s/w and send an email in the 
#			event of failure.
#
# Author:		Anthony Firmin, FCCL
#
# Date Written:		10/7/01
#
# Change history:	
#
#
###################################################################################

# set -x

###################################################################################
##########################   MAIN CODE   ##########################################
###################################################################################

/opt/SUNWexplo/explorer > /usr/local/logs/explorer.log

if [[ $? -eq 0 ]]
then
	mail anthony@fccl.co.uk <<EOT1
Subject: Explorer Succeeded
EOT1
else
	mail anthony@fccl.co.uk <<EOT2
Subject: Explorer Failed
EOT2
fi

exit
