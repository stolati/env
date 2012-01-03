#!/usr/bin/env bash

#configuration
ACTIVE_HISTORY=false #true

#set -u #unbound variable (no more used, because it kill completion on some envs
export et="${et:-`pwd`}" #home path (E.T. phone home)

export bin="$et/env/bin"

###########################
# Bash environment
###########################

chmod a+x $et/env/bin/*
export PATH=".:$PATH:$et/env/bin"
export CDPATH="${CDPATH:-}:$et"

export SHELL="$et/env/bin/shell"

set show-all-if-ambiguous on #show completion instead of bell
set horizontal-scroll-mode on #dont wrap when line is too long

#TODO change $INPUTRC and put .inputrc
export TERM=xterm ; tput init #screen is not known everywhere
#export TERM=ansi ; tput init #screen is not known everywhere

set -o ignoreeof  #^D dont exit
set -o noclobber  #dont overwrite when doing file redirection
#this is no set (even if it's great) because completion code give an error ( on some "exclude" variable )
#set -o nounset    #err when use unset variable

shopt -s cdspell #correct small typo in paths
#shopt -s histappend #append history when close, dont ovewrite
shopt -s checkwinsize #check the windows size after each command
shopt -s no_empty_cmd_completion #dont try to complete on emtpy line

#history stuffs
if $ACTIVE_HISTORY; then

  HISTSIZE=100000
  HISTFILESIZE=${HISTSIZE}00
  PROMPT_COMMAND="history -a" #write the previous line to disk each time
  HISTCONTROL="ignoreboth" #duplicates / begin by space
  HISTFILE="$et/env/generated/bash_history_$(date +%Y%m%d)"
  HISTIGNORE='a:b:c:d:e:f:g:h:i:j:k:l:m:o:p:q:r:s:t:u:v:w:x:y:z' #ignore ls, bg, fg, exit and duplicate
  #TODO create a hist command, for history interrogation
  #alias histAllTime='cat $HISTFILE | sort | uniq -c | sort | head -100'
  #alias histCmd="cat $HISTFILE | cut -d' ' -f1 | sort | uniq -c | sort | head -100"

else

  HISTSIZE=1
  HISTFILESIZE=1
  HISTFILE="/dev/null"
fi


#adding colors
export CLICOLOR=1

#set the PS1_COLOR in the specialized scripts
export PS1_RESET="`term_color reset`"
#to set by the others scripts

PS1='\[$PS1_COLOR\]$?/\D{%H%M%S}:\u@\h\w>\[$PS1_RESET\] '

#python
export PYTHONDONTWRITEBYTECODE=true
export PYTHONNOUSERSITE=true
export PYTHONPATH="${PYTHONPATH:-}:$et/env/lib/python"

###########################
# Git setup
###########################
git config --global user.name "Stolati"
git config --global user.email "stolati@gmail.com"


###########################
# VIM commands
###########################

#EDITOR="vim -u $et/env/conf/vimrc -i $et/env/generated/viminfo -n"
EDITOR="vim -u $et/env/conf/vimrc -i /dev/null -n"

#bash mode vi
set -o vi
set editing-mode vi
set convert-meta on

bind -m vi-insert "\C-p":dynamic-complete-history # ^p check for partial match in history
bind -m vi-insert "\C-n":menu-complete # ^n cycle through the list of partial matches
bind -m vi-insert "\C-l":clear-screen # ^l clear screen

#editor command


###########################
# Aliases
###########################

#reserved by bash:
#! case do done elif else esac fi for function if in select then until while { } time [[ ]]

#alias a=
#alias b=
alias c='$CD'
#alias d=
alias e=profile_editor_smartLaunch
alias f=profile_utils_smartFind
alias g='egrep --color'
#alias h=
#alias i=
#alias j=
#alias k=
alias l='$LS'
alias m="./launsh.bash"
#alias n=
#alias o=
alias p="profile_utils_dirqueue" #push a
alias q=exit
#r(){ echo "$*" | bc ;}
alias r='rm'
alias rr='rm -rf --'
alias s=shell
alias t="./launch.bash"
#alias u=
w(){ profile_utils_watch "${@:-l}" ; } #watch, l by default
#alias v=
alias x=smartchx
#alias y=
#alias z=

alias tf='tail -f'
alias cp='scp -r'

alias ll='l -ahtr' #if it's not l we want, it's ll
lc(){ ls "$@" | wc -l ; } #count number of files
#TODO why it bug : lt(){ l | tail $1 ; } #l with tail
llt(){ ll | tail $1 ; } #ll with tail

gg(){ g $g "$@" ; } #use g variable for searching
fg(){ find . -type f -print0 | xargs -0 egrep --color -i "$1" ; }

lg(){ l | g "$@" ; }
lgg(){ l | gg "$@" ; }

alias pl='dirs -p -l'

alias ep=profile_editor_editInPath

alias nastyNames="find . -name '*[^a-zA-Z0-9._-]*'"
TODO(){ find . -type f | xargs -n 100 grep -n TODO ; }

alias eof='touchext .eof'
alias EOF='touchext _EOF'

#TODO -(){ return to the previous path }
#TODO ?(){ calcul ;}
#TODO mix cd and e into e



###########################
# change dir
###########################

#!/usr/bin/env bash

CD=profile_editor_smartCd

gen_cmd(){ #<command> <last command values> <parameters>
  typeset cmd="$1" param="$2"
  shift; shift
  while [ $# -ne 0 ]; do
    typeset curCmd="$1"; shift
    $cmd $curCmd $param >/dev/null 2>/dev/null && cmd="$cmd $curCmd"
  done
  echo "$cmd"
}

LS=$(gen_cmd ls / -l -F -G --color=auto --group-directories-first)




#function
#try to cd, if it's a file launch editor instead
profile_editor_smartCd(){
  #only take the first argument
  #the others are for the decoration
  typeset newPath="${1:-$et}"
  if [ -f "$newPath" ]; then
    #if it's a file, maybe we want to edit it
    $EDITOR "$@"
  else
    cd "$newPath"
    $LS
  fi
}

#TODO try to push the directory into the dirqueue
#TODO and then have c and - with more than 2 values
#try to push the directory into the dirqueue
#if it's already the last of the queue, switch with the previous one
# if there is an arg, try to go to the latest which contain the word
#profile_utils_dirqueue(){
  #typeset args="$*"

  #if [ -n "$args" ];then

  #fi

  #set -x
  #typeset previous="`dirs +1 -l `"
  #typeset current="`pwd`"
  #if [ "$current" = "$previous" ]; then
  #  popd
  #  popd
  #  pwd
  #  pushd "$current"
  #else
  #  pushd .
  #fi
#}

#alias up to 10 level
#so i don't have to count when moving
alias ..='$CD ..'
alias ...='$CD ../..'
alias ....='$CD ../../..'
alias .....='$CD ../../../..'
alias ......='$CD ../../../../..'
alias .......='$CD ../../../../../..'
alias ........='$CD ../../../../../../..'
alias .........='$CD ../../../../../../../..'
alias ..........='$CD ../../../../../../../../..'
alias ...........='$CD ../../../../../../../../../..'



###########################
# Editor
###########################

#load the editors values (vim)

#the default editor
EDITOR="vim -u $et/env/conf/vimrc -i $et/env/conf/viminfo -n -X"

#bash mode vi
set -o vi
set editing-mode vi
set convert-meta on

bind -m vi-insert "\C-p":dynamic-complete-history # ^p check for partial match in history
bind -m vi-insert "\C-n":menu-complete # ^n cycle through the list of partial matches
bind -m vi-insert "\C-l":clear-screen # ^l clear screen

#editor command
profile_editor_smartLaunch(){
  if [ -z "$*" ];then
    $EDITOR -
  elif [ -d "$*" ]; then
    $CD "$@"
  else
    $EDITOR "$@"
  fi
}


#edit programm in the path
profile_editor_editInPath(){
  typeset path_prog=`which $1`
  if [ ! -f "$path_prog" ];then
    echo "No program found for [$1]"
    return
  fi
  if [ ! -r "$path_prog" ];then
    echo "No reading permission for [$path_prog]"
    return
  fi

  $EDITOR "$path_prog"
}





#####################
#old settings
#####################

#for humains
alias df='df -h'  #sizes in humain format
alias du='du -h'  #sizes in humain format
alias less='less -r'       # raw control characters
alias whence='type -a'     # where, of a sort
alias wget='wget --no-check-certificate'
alias man='man -a'
alias diff='diff -r'

export SCREEN="screen -c $et/env/conf/screenrc -a"

#shorten most used commands
#?(){ echo "$*" | bc -l ; }
#alias p="project --conf-file=$et/env/conf/project"

alias ss='serv -c $et/env/conf/hosts.lst -s' #connect through ssh
alias sl='serv -c $et/env/conf/hosts.lst -l' #list all awailable servers
alias sf='serv -c $et/env/conf/hosts.lst -f' #connect through ftp

#TODO

#don't take the already opened screen sessions
#alias scre='screen -a -D -R'

#bash variable sheet
# ${toto#reg} delete the shortest match from the left
# ${toto##reg} delete the longest match from the left
# ${toto%reg} delete the shortest from the right
# ${toto%%reg} delete the longest from the right
# ${toto:-lala} $toto or "lala"
# ${toto:=lala} $toto or toto="lala" ; $toto
# ${toto:+lala} $toto and "lala" or ""
# ${toto:?"lala"} $toto or echo "lala"

#TODO secure actions
#alias mv='trash --conf-file=$et/conf/trash --simulate-mv'
#alias cp='trash --conf-file=$et/conf/trash --simulate-cp'
#alias rm='trash --conf-file=$et/conf/trash --simulate-rm'

#####################
# Utils function
#####################

profile_utils_getColorFromEnv(){
  case "$1" in
    reset) echo "\e[0m";; #reset color
    prod) echo "\e[1;31m";; #red
    re7) echo "\e[1;32m";; #green
    dev) echo "\e[1;34m";; #blue
    *) echo "\e[1;37m";; #white
  esac
}

#create a custom watch so i can use my aliases
#Ctrl-c to quit
profile_utils_watch(){
  typeset new="$(eval $@)"
  typeset old
  while true; do
    date
    echo "$new"
    old="$new"
    while [ "X$old" == "X$new" ]; do
      sleep 1
      new="$(eval $@)"
    done
  done
}

#smart find
#TODO make it smarter
profile_utils_smartFind(){
  find . -name "*${@}*"
}

#configuration for pentadactyl
export PENTADACTYL_INIT=":source \"$et/env/conf/pentadactyl.conf\""

#__EOF__


#####################
# Check the environnement
#####################

case "$OSTYPE" in
  *cygwin*)  env="win" ;;
  *linux*) env=lux ;;
  *darwin*) env=mac ;;
  *) env="what" ;;
esac

base_app="$et/app/${env}_app"


#####################
# Alias for executables
#####################
profile_test_exec(){
  [ -f "$1" ] && return 0
  echo "Executable [$1] not found"
  return 1
}

ff_profile="$et/app/firefox_profile"

case "$env" in
  lux)
    ff_path="$base_app/firefox/firefox" ;;
  mac)
    ff_path="$base_app/Firefox.app/Contents/MacOS/firefox-bin"
    ;;
  win)
    ff_path="$base_app/firefox/App/Firefox/firefox.exe"
    ff_profile="$(cygpath -w "$ff_profile")"
    ;;
esac

alias firefox='"$ff_path" -profile "$ff_profile"'
alias ff='nohup "$ff_path" -profile "$ff_profile" >/dev/null 2>&1 &'

#####################
# Load the profile bash
#####################


#!/usr/bin/env bash

#load the configuration
prof_last="$et/env/locals/profile/`whoami`@`hostname`.bash"

if [ ! -f "$prof_last" ]; then
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo "The local last bash don't exists, creating it"
  echo "file : [$prof_last]"
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

  {
    echo '#!/usr/bin/env bash'
    echo ''
    echo "#bash for user `whoami`@`hostname`"
    echo 'TYPE_ENV= #dev|prod|re7'
    echo ''
    echo '#__EOF__'
  } >> $prof_last

fi

chmod u+x "$prof_last"

. "$prof_last"
unset prof_last

if [ -z "${PS1_COLOR:-}" ]; then
  case "${TYPE_ENV:-}" in
    dev) PS1_COLOR=`term_color fg_blue`;;
    prod) PS1_COLOR=`term_color fg_red`;;
    re7) PS1_COLOR=`term_color fg_green`;;
    *) PS1_COLOR="`term_color fg_red`!!! PS1_COLOR not set !!!`echo``term_color fg_red``term_color bg_yellow`" ;;
  esac
fi

export TYPE_ENV="${TYPE_ENV:-}"
export SCREEN_SIZE="${SCREEN_SIZE:-150x51}"






#__EOF__
