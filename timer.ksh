#!/usr/bin/ksh

# set -x

count=0;
mins=0;
rate=825;
for i in $(df  -k | egrep -v "avail|proc|fd|mnt|run" | awk '{print $3}')
do
        let count=$count+$i
done;
let count=$count/1000;
let mins=$count/$rate;
let count=$count/1000;

print "Backup of data filesystems, "$count" GB, will take "$mins "minutes";
