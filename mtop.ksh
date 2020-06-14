#!/usr/bin/ksh

tester=0

function settrap {
	print ""
	print ""
	print "Exiting..."
	print ""
	rm /tmp/mtop*.$$
	exit
}

trap 'settrap' INT TERM

me=$(who am i | awk '{print $2}')

while [[ $tester -eq 0 ]]
do

	HEADER="NALATAM TOP SESSIONS UTILITY ----  mtop ---- "$(date)
	print "" > /tmp/mtop.$$

	/usr/ucb/ps -aux | grep -v $me | head -20 | grep -v aux > /tmp/mtop_1.$$

	grep "USER       PID" /tmp/mtop_1.$$ >> /tmp/mtop.$$

	print "" >> /tmp/mtop.$$

	grep -v "USER       PID" /tmp/mtop_1.$$ >> /tmp/mtop.$$

	clear

	print $HEADER

	cat /tmp/mtop.$$

	print ""

	print "Hit Ctrl & c to break out"

	sleep 5

done

