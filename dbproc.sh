#  Count of Linux processes by database
#   - check in instance is active
#
#
#  Function Declarations
#
function count_it
{
  DB=$1
#
  cnt_proc=0
  cnt_conn=0
  ps -ef|grep ora_dbw0_$DB$ | grep -v -q grep
  if (( $? == 0 ))
  then
   cnt_proc=$(ps -ef|grep -E $DB$ | wc -l)
   cnt_conn=$(ps -ef|grep "oracle${DB}.*(LOCAL="| grep -v grep | wc -l)
  fi
  printf '%-13s %-11s %-11s\n' $DB $cnt_proc $cnt_conn
}
function count_listener
{
  cnt_proc=0
  ps -ef|grep 'tnslsnr LISTENER'  | grep -v -q grep
  if (( $? == 0 ))
  then
   cnt_proc=$(ps -ef|grep -E 'tnslsnr LISTENER' | grep -v grep | wc -l)
  fi
  printf 'Listener      %-11s \n' $cnt_proc
}
#
#
#  START
#
  echo "  SID      Processes Connections"
  echo "__________ _________ ___________"
#
DB_CNT=$(grep -v -e '^#' -e '^*' -e '^$' /etc/oratab | wc -l)
#
if (( $DB_CNT > 0 ))
then
 grep -v -e '^#' -e '^*' -e '^$' /etc/oratab | while read LINE
 do
  set $LINE
  DB=$(echo $1 | cut -f1 -d:)
  count_it $DB
 done
 count_listener
fi
#
