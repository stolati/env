#!/usr/bin/env bash

testFile(){ #<file>
  if [ -f "$1" ]; then
    echo "Already exist : [$1]"
  else
    echo "Install : Creating [$1]"
  fi

  test ! -f "$1"
}

echo 'Give your $et [default : '`pwd`']'
read myHome

[ -z "$myHome" ] && myHome=`pwd`
echo $myHome

if echo "$myHome" | grep ' ' >/dev/null ; then
  echo "!!! your home contains spaces, are you really sure ? (y/n)!!!"
  read res
  if [ y != "$res" ]; then
    echo "Go find a better home, and install again when it's done"
    exit 1
  fi
  printf "Segfault..."
  sleep 1
  echo " kidding"
fi

f=$myHome/.bash_profile
testFile "$f" && {
  echo "cd '$myHome'"
  echo "source '$myHome/env/conf/profile.bash'"
} >> $f

f=$myHome/.bashrc
testFile "$f" && {
  echo "cd '$myHome'"
  echo "source '$myHome/env/conf/profile.bash'"
} >> $f

echo done
#__EOF__#
