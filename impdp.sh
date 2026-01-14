#########################################
#                                       #
#  SCRIPT NAME:   impdp.sh              #
#  AUTHOR:        Harris Fungwi         #
#  DATE:          JAN 29, 2024          #
#                                       #
#########################################
#
#  Import of database tables
#
#
export ORACLE_SID=TESTDB
export ORAENV_ASK=NO ; . oraenv ; unset ORAENV_ASK
export ORACLE_PASSWORD=$(get_pw :ORACLE:${ORACLE_SID}:ORACLE_DP:)
#
impdp oracle_dp/$ORACLE_PASSWORD \
  DIRECTORY=data_pump_dir \
  DUMPFILE=TESTDB_expdp_dev_tabs.dmp \
  LOGFILE=TESTDB_impdp_dev_tabs.log \
  FULL=N \
  #REMAP_SCHEMA= \
  #REMAP_TABLE= \
  #TABLE_EXISTS_ACTION=REPLACE
#
