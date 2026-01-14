#####################################################################
# SCRIPT_NAME   : tblsp_ck.sh
# AUTHOR        : Harris Fungwi
# DATE          : 24-11-2023
#####################################################################
#
# notify dba of tablespace filling up
# (need one scripts loop round all databases / call scripts for individual db)
#
#!/bin/bash
#
# Set environment

export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/19.3.0.0/dbhome_2
export DBA=$ORACLE_BASE/admin
PATH=$PATH:$ORACLE_HOME/bin
export ORACLE_SID=""
#
#
#

# Set your email recipients
RECIPIENTS=#input email here eg "example@gmail.com"
#
#
# Set the threshold percentage for tablespaces
THRESHOLD_PERCENT=90
#
# Read the database names from etc/oratab
database_names=$(grep -v '^#' /etc/oratab | cut -d':' -f1 | grep -v 'dummy*' | grep -v 'patch19300')
# Loop through each database name
for     ORACLE_SID in $database_names
do
#
# set DB as database names
#
DB=$ORACLE_SID
#
#export system password
export sys_pw=$(get_pw :ORACLE:${ORACLE_SID}:SYSTEM:)
#
# Get tablespace usage information
TABLESPACE_USAGE=$(sqlplus -S system/$sys_pw@$DB << EOF
SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF
SELECT TABLESPACE_NAME, ROUND((sum(BYTES) /sum(MAXBYTES)) * 100) AS USAGE_PERCENT
from dba_data_files
where tablespace_name not in ('UNDOTBS1')
and maxbytes > 0
group by tablespace_name
order by tablespace_name;
EXIT;
EOF
)
#
#
echo -e "$DB:\n $TABLESPACE_USAGE"
#
# Check if any tablespace exceeds the threshold
while read -r line; do
TABLESPACE_NAME=$(echo "$line" | awk '{print $1}' )
USAGE_PERCENT=$(echo "$line" | awk '{print $2 }')


   if [ "$USAGE_PERCENT" -gt "$THRESHOLD_PERCENT" ]; then
    SUBJECT="ORACLE ALERT:$DB $TABLESPACE_NAME TABLESPACE USAGE EXCEEDS $THRESHOLD_PERCENT%"
    BODY="$DB $TABLESPACE_NAME Tablespace usage is $USAGE_PERCENT%. Consider resizing or adding datafiles."
    FROM="oracle_alerts@localhost.com"

    echo -e "$BODY" | mail -r "$FROM" -s "$SUBJECT" "$RECIPIENTS"
 fi
done <<< "$TABLESPACE_USAGE"

done
