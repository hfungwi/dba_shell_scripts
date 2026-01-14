#!/bin/bash

############################
# COLD BACKUP SCRIPT       #
# FOR RMAN                 #
# WRITTEN BY Harris Fungwi #
# 17/04/2023               #
############################

#Production scripts will be database specific as they are run via appworx.
#SETENV
export ORACLE_BASE=/u01/app/oracle
if [ -n "$DB" ]
then
    export ORACLE_SID=$DB
else
    export DB=$ORACLE_SID
fi
export ORAENV_ASK=NO ; . oraenv ; unset ORAENV_ASK
export NLS_DATE_FORMAT='yyyy/mm/dd hh24:mi:ss'
export NLS_LANG=american_america.al32utf8

#delete logfile contents so that it can be overwritten
> /u02/fast_recovery_area/$DB/logs/coldbackup.log

# connect to rman, Run Backup, and Redirect output log to a file

rman target / @/u01/app/oracle/admin/$DB/rman/coldbackup.rman | tee /u02/fast_recovery_area/$DB/logs/coldbackup_$(date +'%Y%m%d').log


#Check for errors in the backup log and send alert if any errors are detected

ERRORS=$(grep -E -i -e ora- -e rman- /u02/fast_recovery_area/$DB/logs/coldbackup.log)

if [ -n "$ERRORS" ]; then
        SUBJECT="ORACLE ALERT:Errors occured during the backup of $DB"
        BODY="The following errors occured during the $DB BACKUP:\n\n $ERRORS"
        RECIPIENTS="example@localhost.com"
        FROM="oracle_alerts@localhost.boeing.com"

echo -e "$BODY" | mail -r "$FROM" -s "$SUBJECT" "$RECIPIENTS"
fi
