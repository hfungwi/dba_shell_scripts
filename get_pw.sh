if test -d /u01/pwdb
then
  PW_DIR=/u01/pwdb
else
  exit 1
fi
#
GROUP=$(id -gn)
IN_ACCOUNT=$1
#
if test -a $PW_DIR/$GROUP/$IN_ACCOUNT
then
gpg -q --batch --passphrase  testpassphrase12345 --decrypt $PW_DIR/$GROUP/$IN_ACCOUNT
else
  echo  NotFound
  exit 1
fi
#usage
#get_pw :ORACLE:{$ORACLE_SID}:{$ACCOUNT}:
