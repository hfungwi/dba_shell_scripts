# Read the database names from etc/oratab
database_names=$(grep -v '^#' /etc/oratab | cut -d':' -f1 | grep -v dummy*)
# Loop through each database name
for     ORACLE_SID in $database_names
do
  # Check if the process is running
  ps_output=$(ps -ef|grep -e ora_smon_$ORACLE_SID |grep -v grep)

  # If the process is running, display "up" message
  if [ -n "$ps_output"  ]; then
    echo "============================"
    echo "$ORACLE_SID is up and running."
 else
    echo "======================"
    echo "$ORACLE_SID is down."
fi
done
    echo "============================"

