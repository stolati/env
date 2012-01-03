#!/usr/bin/env bash

#from http://intranet.ctlmcof.fr/config/proxy.pac
export http_proxy="172.18.234.15:3128"
TYPE_ENV=dev
SCREEN_SIZE=198x71

alias open=explorer

#generate a fortune
export COWPATH=$et/env/locals/bin/share/cows
fun(){
  clear;
  #choose a random cow
  fortune -o | cowthink -f "$(ls $COWPATH | shuf -n1)" -n
}
#fun

#eval "$(_proAliasPath $et)"
#eval "$(_proAliasPath $et/env env)"
#__EOF__
