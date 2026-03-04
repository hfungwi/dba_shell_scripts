###############################################
# Written by Harris Fungwi
# The following will;
# (1)Set your fra destination and size
# (2)set required permissions
# (3)backup the controlfile to trace
# 16 OCT, 2023
############################################

#setenv
# db_recovery_file_dest and archive_log_dest cannot both be set

export TNS_ADMIN=$ORACLE_BASE/admin/tns_admin
export ORACLE_SID=ORCL #replace
export ORAENV_ASK=NO ; . oraenv ; unset ORAENV_ASK

rm -f /u02/fast_recovery_area/${ORACLE_SID}/controlfile_recreate
mkdir -p /u02/fast_recovery_area/$ORACLE_SID/controlfile
mkdir -p /u02/fast_recovery_area/$ORACLE_SID/spfile
mkdir -p /u02/fast_recovery_area/$ORACLE_SID/logs
mkdir -p /u02/fast_recovery_area/$ORACLE_SID/autobackup
chmod 770 /u02/fast_recovery_area/$ORACLE_SID/controlfile
chmod 770 /u02/fast_recovery_area/$ORACLE_SID/spfile
chmod 770 /u02/fast_recovery_area/$ORACLE_SID/autobackup

sqlplus /nolog <<-EOF
  SET SQLPROMPT " "
CONNECT / as sysdba
  SET ECHO ON
  SET FEEDBACK ON
  SET VERIFY ON

  PROMPT
  PROMPT undo parameters for re-run...
  PROMPT
--
-- to backout changes use the below alter system command
-- alter system set db_recovery_file_dest='' scope=both;
--
     ALTER SYSTEM RESET db_recovery_file_dest sid='*'
     ALTER SYSTEM RESET db_recovery_file_dest_size sid='*'


  PROMPT
  PROMPT
  PROMPT creating recovery_file_dest ...
  PROMPT
  PROMPT

-- set recovery_file_dest size and location
     ALTER SYSTEM SET db_recovery_file_dest_size=10G scope=both;
     ALTER SYSTEM SET db_recovery_file_dest='/u02/fast_recovery_area/' scope=both; #replace

-- display changes
  show parameter recovery

-- backup controlfile to trace
  PROMPT
  PROMPT
  PROMPT taking backup of control file...
  PROMPT
  PROMPT
     ALTER DATABASE BACKUP controlfile TO TRACE;
     ALTER DATABASE BACKUP controlfile TO TRACE AS '/u02/fast_recovery_area/${ORACLE_SID}/controlfile_recreate';
exit
EOF
