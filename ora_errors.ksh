##################################################################################

refresh_errors () {

REFRESH_FILE=$1
print "" >> $MAIL_FILE 
print "SAS_AVAILABLILITY: REFRESH ERRORS $REFRESH_FILE" >> $MAIL_FILE
print "" >> $MAIL_FILE
print "              REFRESH MAY NOT HAVE COMPLETED SUCCESSFULLY" >> $MAIL_FILE
print "" >> $MAIL_FILE
print "=======================================================================" >> $MAIL_FILE
print "" >> $MAIL_FILE 
cat $REFRESH_FILE >> $MAIL_FILE
print "." >> MAIL_FILE

mail $MAILING_LIST < $MAIL_FILE

}

###################################################################################

cd /u01/home/sdbadm/logs

for i in $(ls refresh_all.log.$(date "+%y%m%d")* refresh_sample.log.$(date "+%y%m%d")*)
do
        if [[ -f $i ]]
        then
                if grep -h ORA $i
                then

                	refresh_errors $i

                fi
        fi
done
