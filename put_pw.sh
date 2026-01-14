if test -d /u01/pwdb
then
  PW_DIR=/u01/pwdb
else
  exit 1
fi
#
GROUP=$(id -gn)
IN_ACCOUNT=$1
IN_PASSWORD=$2
#
if test -d $PW_DIR/$GROUP
then
  if test -a $PW_DIR/$GROUP/$IN_ACCOUNT
  then
    rm  $PW_DIR/$GROUP/$IN_ACCOUNT
  fi
  echo $IN_PASSWORD | gpg --batch --passphrase testpassphrase12345 --symmetric > $PW_DIR/$GROUP/$IN_ACCOUNT
  chmod 770 $PW_DIR/$GROUP/$IN_ACCOUNT
else
  exit 1
fi
##usage
#put_pw :ORACLE:{$ORACLE_SID}:{$ACCOUNT}:
