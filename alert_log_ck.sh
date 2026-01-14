#####################################################################
# SCRIPT_NAME   : alertlogck.sh
# AUTHOR        : Harris Fungwi
# DATE          : 24-11-2023
#####################################################################
#
# notify DBA of critical errors in alert log
#!/bin/bash
#
#Following required for running via crontab

export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/19.3.0.0/dbhome_2
export DBA=$ORACLE_BASE/admin
PATH=$PATH:$ORACLE_HOME/bin
export ORACLE_SID=""

#
#
# Set your email recipients
RECIPIENTS= # set recipients here eg "example@example.com"
#
#
# Read the database names from etc/oratab
database_names=$(grep -v '^#' /etc/oratab | cut -d':' -f1 | grep -v 'dummy*' | grep -v 'patch19300*')
# Loop through each database name
for     ORACLE_SID in $database_names
do
#
# set DB as database names
#
DB=$ORACLE_SID
db=$(echo "$DB" | tr -s '[:upper:]' '[:lower:]' )
#
#
#
#set alert log
ALERT_LOG=$ORACLE_BASE/diag/rdbms/${db}/${DB}/trace/alert_${DB}.log
#
#
# Get the last 500 lines of the alert log
ERRORS_FOUND=$(tail -n 500 $ALERT_LOG | grep -E "ORA-00600|ORA-07445|ORA-04031|ORA-01092|ORA-01578|ORA-03113|ORA-12012|ORA-00257|ORA-04021|ORA-00313
|ORA-1652|ORA-01565|ORA-19815|ORA-19804|ORA-19809")
#
#
#
# If errors are found, send an email
if [ -n "$ERRORS_FOUND" ]; then
  SUBJECT="ORACLE ALERT: CRITICAL ERROR[S] DETECTED IN THE $DB ALERT LOG"
  BODY="The following critical Errors have been detected in the $DB alert log:\n\n $ERRORS_FOUND\n\n IMMEDIATE INTERVENTION REQUIRED!"
  FROM="oracle_alerts@localhost.com"

  echo -e "$BODY" | mail -r "$FROM" -s "$SUBJECT" "$RECIPIENTS"
  cp "$ALERT_LOG" "${ALERT_LOG%.*}_$(date +'%Y%m%d_%H%M%S').${ALERT_LOG##*.}"
  > $ALERT_LOG
fi

done
