#!/usr/bin/ksh

tester=0


function settrap {
        print ""
        print ""
        print "Exiting..."
        print ""
        rm /tmp/sar_disks*.$$
        exit
}

trap 'settrap' INT TERM

print ""
print "Gathering data, this may take a few seconds..."
print ""

while [[ $tester -eq 0 ]]
do

sar -d 2 3 | grep -v ",[abcdefgh]" | awk '{} {
        if ( $2 == "nfs1" ) 
                print $1
        if ( $2 == "0" && $3 == "0.0" && $4 == "0" && $5 == "0" && $6 == "0.0" && $7 == "0.0" )
                name = "fred"
        else    if ( $1 ~ /ssd/ )
                name = "fred"
        else    if ( $2 != "nfs1" )
                print $0
} {} '  > /tmp/sar_disks_1.$$ 2>&1

grep avque /tmp/sar_disks_1.$$ > /tmp/sar_disks.$$

print "" >> /tmp/sar_disks.$$

sed -e "1,/Average/d" /tmp/sar_disks_1.$$ >> /tmp/sar_disks.$$

clear

print "NALATAM DISK ACTIVITY UTILITY ----  mdisks ---- "$(date)
print ""

cat /tmp/sar_disks.$$

print ""

print "Hit Ctrl & c to break out"

done
