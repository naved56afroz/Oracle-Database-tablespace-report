#!/bin/ksh
#set -o xtrace
#
##################################################################
###  Script:   Report.sh                                       ###
###                                                            ###
###  Purpose:  Oracle database custom report                   ###
###                                                            ###
##    Usage:  Report.sh Identifier_Name                        ###
###           Create file in /home/oracle/scripts              ###
###      as Identifier_Name_db_list.lst containing all DB's    ###
###  Inputs:  {DBLIST ,Sql script,Recipient list,format file   ###
###                                                            ###
###  Output:  ORACLE DATABASE  Usage report                    ###
###                                                            ###
###  Author: Naved Afroz   naved56afroz@gmail.com              ###
###                                                            ###
###                                                            ###
##################################################################

##Check if previous run was success of failed

LOCK=/home/oracle/scripts/tbs.lck
if [ -f $LOCK ]
  then
    echo " another  instance already running or previous run failed remove /home/oracle/scripts/tbs.lck and start again"
exit;
fi

touch $LOCK
cleanup()
{
if [ -f $1 ]
  then
    echo " $1 file  exists."
rm $1
fi
}

## Function to connect to respective database and run sql script 

checkUsage()
{
 echo "Checking report " >> $LOG
 DBUSR=A_USER_I
 DBPASSWD=`/dbw/src/Processe/NoverCross ID=a_user_i DB=REPDB 2>/dev/null`
 CONNECT="$CON"
if [ $DBLIST ]
then
echo "Found the db list" >> $LOG
 cat $DBLIST | while read LINE
 do
   DB_ID=`echo $LINE | awk '{ print $1 }'`
   if [ $DB_ID ]
   then
     echo "connect ${DBUSR}/${DBPASSWD}@${DB_ID}" > ${CONNECT}
     timeout 1m $ORACLE_HOME/bin/sqlplus -s /nolog << EOF
      @${CONNECT}
       set pages 100
       set feedback off
       @/home/oracle/scripts/set_markup.sql
       spool $LOG
       @/home/oracle/scripts/usage_report.sql
       spool off
      EXIT
EOF

cat $LOG>>$LOG1
fi
done
else
echo "No database list found" >> $LOG
fi
}

## Funtion to trigger email alerts

sendmail()
{
echo "executing sendmail"
NOW=$(date +"%d-%m-%Y  %T")
export MAILTO="`cat /home/oracle/scripts/$1_mail_list.lst`"
export SUBJECT="Subject: Oracle DB Tablespace >75% Report for $1 Application as on  $NOW"
(
 echo "To : `cat /home/oracle/scripts/$1_mail_list.lst`"
 echo "Subject: $SUBJECT"
 echo "From: <source_hostname>@noreply.com"
 echo "MIME-Version: 1.0"
 echo "Content-Type: text/html"
 echo "Charset: iso-8859-1"
 echo "Content-Disposition: inline"
 cat $LOG1
) | /usr/sbin/sendmail  $MAILTO
}


################
# Main Program #
################

## Variables
#LOCK=/home/oracle/scripts/tbs.lck
LOG1=/home/oracle/scripts/all_db_usage1.log
LOG=/home/oracle/scripts/all_db_usage.html
CON=/home/oracle/scripts/conn1.txt
DBLIST=/home/oracle/scripts/$1_db_list.lst
LOG=/home/oracle/logs/$1_usage_status.`date +%d-%m-%Y`.log
MAIL_TO=/home/oracle/scripts/$1_mail_list.lst
. $HOME/bin/setenv ORAINF

checkUsage $DBLIST
sendmail $1

cleanup $CON
cleanup $LOG
cleanup $LOG1
cleanup $LOCK
