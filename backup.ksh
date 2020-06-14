#!/usr/bin/ksh

/usr/local/bin/backup_system_nsr > /usr/local/logs/backup_system_nsr.log 2>&1

# lp -o2up /usr/local/logs/backup_system_nsr.log > /dev/null 2>&1

cp /usr/local/logs/backup_system_nsr.log /usr/local/logs/backup_system_nsr.log.$(date "+%d%m%y")

