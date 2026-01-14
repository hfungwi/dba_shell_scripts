#########################################
#                                       #
#  SCRIPT NAME:   full_expdp.sh         #
#  AUTHOR:        Harris Fungwi         #
#  DATE:          Oct 29, 2025          #
#                                       #
#########################################
#
# Nightly export of the database
#
#
export ORACLE_SID=TESTDB
export ORAENV_ASK=NO ; . oraenv ; unset ORAENV_ASK
export SYS_PW=$(get_pw :ORACLE:${ORACLE_SID}:SYSTEM:)
export ORACLE_PASSWORD=$(get_pw :ORACLE:${ORACLE_SID}:ORACLE_DP:)
#
sqlplus oracle_dp/$ORACLE_PASSWORD  <<-EOF
  set serveroutput on size 999999
  BEGIN
    FOR i IN (SELECT table_name
              FROM   user_tables
              WHERE
              regexp_like(table_name,'SYS_EXPORT_FULL_[0123456789][0123456789]')
             )
      LOOP
        EXECUTE IMMEDIATE ('DROP TABLE '||i.table_name||' PURGE');
        dbms_output.put_line('Dropped table '||i.table_name);
      END LOOP;
  END;
  /
  exit
EOF
#
sqlplus -s /nolog <<-EOF
  -- >
 connect system/${SYS_PW}
    ALTER SYSTEM FLUSH SHARED_POOL ;
    exit
EOF
#
#
expdp oracle_dp/$ORACLE_PASSWORD \
  DIRECTORY=ora_export \
  DUMPFILE=${ORACLE_SID}_expdp.dmp \
  REUSE_DUMPFILES=YES \
  LOGFILE=${ORACLE_SID}_dp.log \
  COMPRESSION=ALL COMPRESSION_ALGORITHM=MEDIUM \
  FULL=YES \
  METRICS=Y \
  EXCLUDE=SCHEMA:\"= \'ORACLE_DP\'\" \
  FLASHBACK_TIME=SYSTIMESTAMP;
#
