#!/usr/bin/ksh
#
###################################################################################
#
# Name:                 sas_check_jobs
#
# Paramters:            None
#
# Description:          
#
# Exit codes:           None
#
# Author:               Anthony Firmin, FCCL
#
# Date Written:         October 2001
#
# Change history:
#
#
###################################################################################
#

# set -x

marker=0

user=$(whoami)

if [[ $user = "adelel" || $user = "root" || $user = "afirmin" || $user = "sdbadm" ]]
then
	user="adelel jonh robd visitor1 visitor2"
fi

# for i in adelel jonh robd
for i in $(print $user)
do
	marker=0
	ps -ef | grep $i | egrep -v "\?|ksh|grep|print|dt|sqlplus|mail|tail" | \
		awk '{print $2 "," $5 "," $7 "," $9}' > /tmp/scj.out 2>&1; 
	if grep pts /tmp/scj.out > /dev/null 2>&1
	then
		grep -v sas /tmp/scj.out >> /tmp/scj2.out
		for mpid in $(grep sas /tmp/scj.out | awk '{FS=","}{print $1}{}')
		do
			ps -ef | grep -v grep | grep $mpid | awk '{print $2","$5"-"$6","$8","$10}{}' | \
				grep $mpid >> /tmp/scj2.out
		done
		cat /tmp/scj2.out | sed -e "s/\-dmr/Online/g" | sed -e "s/\-sysin/Batch/g" > /tmp/scj.out
	fi
	if [[ $(cat /tmp/scj.out | wc -l) -gt 0 ]]
	then
		marker=1
		print ""
		print $i
		print "======"
		print "Process ID	Time started	CPU Used	Session Type"
		print "==========	============	========	============"
		for h in $(cat /tmp/scj.out | sed -e "s/\-dmr/Online/g" | sed -e "s/\-sysin/Batch/g")
		do
			if print $h | grep "\-" > /dev/null 2>&1
			then
				print $h | awk '{FS=","}{print $1 "\t\t" $2 "\t\t" $3 "\t\t" $4}{}'
			else
				print $h | awk '{FS=","}{print $1 "\t\t" $2 "\t" $3 "\t\t" $4}{}'
			fi
			pid=$(print $h | awk '{FS=","}{print $1}{}')
			for j in  $(ptree $pid | grep oraclesasdb | awk '{print $1}')
			do
        			ps -ef | grep $j | egrep -v "grep|print" > /tmp/scj3.out
				if [[ $(cat /tmp/scj3.out | awk '{print $9}') = "oraclesasdb" ]]
				then
					cat /tmp/scj3.out | \
					awk '{print $2 "\t\t" $5"-"$6 "\t\t" $8 "\t\t" $9}' | \
					sed -e "s/oraclesasdb/Oracle Process/g"
				else
					cat /tmp/scj3.out | \
					awk '{print $2 "\t\t" $5 "\t" $7 "\t\t" $8}' | \
					sed -e "s/oraclesasdb/Oracle Process/g"
				fi
				rm /tmp/scj3.out
			done
		done
	fi

	rm /tmp/scj*.out


#	Look for Batch jobs...

	if [[ $(ps -ef | grep $i | grep sysin | grep "\?" | egrep -v "ksh|grep|dt|sqlplus|mail|tail" | \
		awk '{print $2 "," $5 "," $7 "," $9}' > /tmp/scj.out 2>&1; \
		cat /tmp/scj.out | wc -l) -gt 0 ]]
	then
		for h in $(cat /tmp/scj.out | sed -e "s/\-dmr/Online/g" | sed -e "s/\-sysin/Batch/g")
		do
			if [[ $marker -eq 0 ]]
			then
				marker=1
				print ""
				print $i
				print "======"
				print "Process ID	Time started	CPU Used	Session Type"
				print "==========	============	========	============"
			fi
			print $h | awk '{FS=","}{print $1 "\t\t" $2 "\t" $3 "\t\t" $4}{}'
			pid=$(print $h | awk '{FS=","}{print $1}{}')
			for j in  $(ptree $pid | grep oraclesasdb | awk '{print $1}')
			do
        			ps -ef | grep $j | egrep -v "grep|print" | \
					awk '{print $2 "\t\t" $5 "\t" $7 "\t\t" $8}' | \
					sed -e "s/oraclesasdb/Oracle Process/g"
			done
		done
	fi

#	Look for old un-owned sessions...
	
	if [[ $(ps -ef | grep $i | grep -v sysin | grep "\?" | egrep -v "ksh|grep|dt|sqlplus|mail|tail" | \
		awk '{print $2 "," $5 "," $6 "," $8 "," $10}' > /tmp/scj.out 2>&1; \
		cat /tmp/scj.out | wc -l) -gt 0 ]]
	then

		# set -x
		for h in $(cat /tmp/scj.out | sed -e "s/\-dmr/Online/g" | sed -e "s/\-sysin/Batch/g")
		do
			if [[ $marker -eq 0 ]]
			then
				marker=1
				print ""
				print $i
				print "======"
				print "Process ID	Time started	CPU Used	Session Type"
				print "==========	============	========	============"
			fi
			if [[ $(print $h | awk '{FS=","}{print $3}{}') == "?" ]]
			then
				z=$(uo_pid=$(print $h | awk '{FS=","}{print $1}{}');ps -ef | grep $i | grep $uo_pid | \
					grep -v grep | sed -e "s/\-dmr/Online/g" | sed -e "s/\-sysin/Batch/g" | \
					awk '{print $2 "," $5 "," $7 "," $9}')
				print $z | awk '{FS=","}{print $1 "\t\t" $2 "\t" $3 "\t\t" $4}{}'
			else
				print $h | awk '{FS=","}{print $1 "\t\t" $2, $3 "\t\t" $4 "\t\t" $5}{}'
			fi
			pid=$(print $h | awk '{FS=","}{print $1}{}')
#			for j in  $(ptree $pid | grep oraclesasdb | awk '{print $1}')
#			do
#        			ps -ef | grep $j | egrep -v "grep|print" | awk '{print $2 "\t" $5, $6 "\t\t" $8 "\t\t" $10}' | \
#					sed -e "s/oraclesasdb/Oracle Process/g"
#			done
                        for j in  $(ptree $pid | grep oraclesasdb | awk '{print $1}')
                        do
                                ps -ef | grep $j | egrep -v "grep|print" > /tmp/scj4.out
                                if [[ $(cat /tmp/scj4.out | awk '{print $9}') = "oraclesasdb" ]]
                                then
                                        cat /tmp/scj4.out | \
                                        awk '{print $2 "\t\t" $5"-"$6 "\t\t" $8 "\t\t" $9}' | \
                                        sed -e "s/oraclesasdb/Oracle Process/g"
                                else
                                        cat /tmp/scj4.out | \
                                        awk '{print $2 "\t\t" $5 "\t" $7 "\t\t" $8}' | \
                                        sed -e "s/oraclesasdb/Oracle Process/g"
                                fi
                                rm /tmp/scj4.out
                        done

		done
		set +x
	fi

	rm /tmp/scj.out
	

done

print ""
