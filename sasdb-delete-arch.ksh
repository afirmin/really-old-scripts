#!/usr/bin/ksh

set -x

cd /u06/oradata/sasdb/arch

ls > /tmp/arch_full.lst

tot_lines=$(cat /tmp/arch_full.lst | wc -l | sed -e "s/ //g")

if [[ $tot_lines -gt 3 ]]
then
        let del_lines=$tot_lines-3
        cat /tmp/arch_full.lst | head -$del_lines > /tmp/arch_del.lst
else
        cat /dev/null > /tmp/arch_del.lst
        del_lines=0
fi

if [[ $del_lines -gt 0 ]]
then
        for i in $(cat /tmp/arch_del.lst)
        do
                print "Deleting $i"
        done
fi

