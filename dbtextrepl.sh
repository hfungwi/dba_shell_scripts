#!/bin/ksh

if [[ -z "$1" ]]
then
  echo usage dbtxtrepl  fromname toname
  exit
fi

if [[ -z "$2" ]]
then
  echo usage dbtxtrepl  fromname toname
  exit
fi

echo This script will replace all occurances of
echo \"$1\"
echo with
echo \"$2\"
echo in all files in the current directory
echo
echo Your current directory is: $(pwd)
echo
echo  Do want to continue?  \(Yes\)

read ans
if [[ $ans = 'Yes' ]]
then
  echo Continuing
else
  echo Exiting
  exit
fi




for file in *; do
  grep -q $1 $file
  if (( $? == 0 ))
  then
    echo repacing text in file  ${file}
    cp -p ${file} ${file}_$$
    sed "s/$1/$2/g" ${file} >${file}_$$
    mv ${file}_$$ ${file}
  else
    echo Bypassing file $file
  fi
done
