#!/usr/bin/env bash

alias play="$et/play-2.0.2/play"
export intellij_home="$et/idea-IC-117.418"
export mongodb_home="$et/mongodb-linux-i686-2.0.6"


idea(){ "$intellij_home/bin/idea.sh" 2>&1 >/dev/null & }
mongo(){ "$mongodb_home/bin/mongod" 2>&1 >/dev/null & }


chat_launch(){
  echo "not full enough yet"
  #typeset ramdir_path="/tmp/ramdisk"

  ##create the tmp path and go under it
  #sudo mkdir -p "$ramdir_path"
  #sudo chmod 777 "$ramdir_path"
  #sudo mount -t tmpfs -o size=1G tmpfs "$ramdir_path"

  #cd "$ramdir_path"

  #git clone git@github.com:stolati/C-h-at.git

  #nohup "$mongodb_home/bin/mongod" 2>&1 >/dev/null &
  #nohup "$intellij_home/bin/idea.sh" 2>&1 >/dev/null &

  #cd "$ramdir_path/C-h-at"

  #play ~run
}



#__EOF__

JAVA_HOME=/usr/local/java/jdk1.7.0_07
PATH=$PATH:$JAVA_HOME/bin
JRE_HOME=/usr/local/java/jre1.7.0_07
PATH=$PATH:$HOME/bin:$JRE_HOME/bin
export JAVA_HOME
export JRE_HOME
export PATH
