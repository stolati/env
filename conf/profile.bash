#!/usr/bin/env bash

#configuration
ACTIVE_HISTORY=true

export et="${et:-`pwd`}" #home path (E.T. phone home)
export bin="$et/env/bin"
export conf="$et/env/conf"

###########################
# often used functions
###########################
str_lower(){ echo "$*" | tr '[:upper:]' '[:lower:]' ; }
str_upper(){ echo "$*" | tr '[:lower:]' '[:upper:]' ; }
pass(){ echo > /dev/null ; } #do nothing
args_toEvaluatedVar(){ #args ...
  while [[ $# -ne 0 ]]; do
    printf '%s' "\"$(echo "$1" | sed 's/"/\\"/g')\" "
    shift
  done
  echo
}

###########################
# Bash environment
###########################

chmod a+x $bin/* #just to be sure
export PATH=".:$PATH:$bin"
#for sudo on ubuntu to not change the PATh
alias sudo='sudo env PATH=$PATH'

export CDPATH="${CDPATH:-}:$et"

export SHELL="$bin/shell" #shell here is
export SCREEN="$bin/my_screen"

set show-all-if-ambiguous on #show completion instead of bell
set horizontal-scroll-mode on #dont wrap when line is too long

#TODO change $INPUTRC and put .inputrc
export TERM=xterm ; tput init #screen is not known everywhere
#export TERM=ansi ; tput init #screen is not known everywhere

set -o ignoreeof  #^D dont exit
#set -o noclobber  #dont overwrite when doing file redirection
#this is no set (even if it's great) because completion code give an error ( on some "exclude" variable )
#set -o nounset #same as set -u   #err when use unset variable
#but on all your scripts, you should use "set -eux"

shopt -s cdspell #correct small typo in paths
#shopt -s histappend #append history when close, dont ovewrite
shopt -s checkwinsize #check the windows size after each command
shopt -s no_empty_cmd_completion #dont try to complete on emtpy line

#history stuffs
if $ACTIVE_HISTORY; then

  HISTSIZE=100000
  HISTFILESIZE=${HISTSIZE}00
  PROMPT_COMMAND="history -a" #write the previous line to disk each time we hit enter
  HISTCONTROL="ignoreboth" #duplicates / begin by space
  HISTFILE="$et/bash_$(date +%Y%m)_.hist"
  #HISTIGNORE= #'a:b:c:d:e:f:g:h:i:j:k:l:m:o:p:q:r:s:t:u:v:w:x:y:z' #ignore ls, bg, fg, exit and duplicate
  #TODO create a hist command, for history interrogation
  #alias histAllTime='cat $HISTFILE | sort | uniq -c | sort | head -100'
  #alias histCmd="cat $HISTFILE | cut -d' ' -f1 | sort | uniq -c | sort | head -100"

else

  HISTSIZE=1
  HISTFILESIZE=1
  HISTFILE="/dev/null"
fi


# Informations about sub bash
export SUB_BASH_LEVEL="$((${SUB_BASH_LEVEL:--1}+1))"
case "$SUB_BASH_LEVEL" in
    0) export PS1_SUB_BASH="" ;;
    1) export PS1_SUB_BASH="-" ;;
    2) export PS1_SUB_BASH="--" ;;
    *) export PS1_SUB_BASH="$BASH_LEVEL-" ;;
esac


#adding colors
export CLICOLOR=1
export PS1_RESET="`term_color reset`"
PS1='\[$PS1_COLOR\]$PS1_SUB_BASH$?/\D{%H%M%S}:\u@\h\w$(__git_ps1 "\n%s")>\[$PS1_RESET\] '
#PS1_COLOR will be set at the end of this script

#python
export PYTHONDONTWRITEBYTECODE=true
export PYTHONNOUSERSITE=true
export PYTHONPATH="${PYTHONPATH:-}:$et/env/lib/python"

###########################
# VIM settings
###########################

#-i /dev/null (instead of viminfo) is where vim put its informations (so when we open a file again, some place are kepts)
#-n is for no swap file
EDITOR="$bin/editor" #because of spaces

#bash mode vi
set -o vi
set editing-mode vi
set convert-meta on

bind -m vi-insert "\C-p":dynamic-complete-history # ^p check for partial match in history
bind -m vi-insert "\C-n":menu-complete # ^n cycle through the list of partial matches
bind -m vi-insert "\C-l":clear-screen # ^l clear screen


###########################
# Short smart aliases
###########################

#the principle is to have a maximum of 1 char aliases
#so each time you have to type more than 1 char command, there is a problem
#(because, you can do a lot with 26 smarts commands)

#reserved by bash:
#! case do done elif else esac fi for function if in select then until while { } time [[ ]]

#a=
#b=
#c= change dir (if dir), edit files (if files), goto home (if empty)
#d=
#e=
#f= find in the current path (regular expression), can have multiples args, default return all
#g= egrep , use -i if only minusclule (like my vim search)
#h=
#i=
#j=
#k=
#l= ls -lrth
#m=
#n=
#o= open the suff it gives dir => nautilus/explorer, pdf => acrobat, etc ... host dependant
#p=
#q= exit
#r= rm
#s= start a new subshell
#t= t <prog> = set the prog as test (with parameters) and launch it, t = launch the setted prog, default = ./launch.bash
#u=
#v=
#w= watch that take my aliases, empty "l" (ls -lrth)
#x= create exe (if not exists), set executable (if exists), empty => launch.bash
#y=
#z=

#try to make t a universal launcher
# use t with parameters to set a launcher (./launch.bash by default) and/or have parameters
# use t alone for launching
# t try to launch the file event if it's not executable
#  - python if end by .py or pyc or pyo
#  - perl, bash, java -jar, scala, etc ...

# d for compression or decompressing
# d zip toto => compress toto
# d something => decompress it if in a compressed format, compress it otherwise

#alias a=
#alias b=
c(){ #[<path>|<files ...>]
  typeset param="${1:-$et}"
  if [[ "X$param" == "X--" ]]; then #special case, all are for the editor
    $EDITOR "$@"
  elif [[ "X$param" == "X-" ]]; then #we have a '-' alias for this case in cd, so it's for editor
    $EDITOR "$@"
  elif [[ -d "$param" ]]; then #moving to the parameter
    cd "$param"
    $LS
  elif [[ -f "$param" ]]; then #editing the parameters
    $EDITOR "$@"
    #try to guess
  elif cd "$param" 2>/dev/null ; then #use the bash guess system
    #autocorrection worked for the cd
    $LS
  else #try to edit it (and create the file before that)
    $EDITOR "$@"
  fi
}
#alias d=
#execute and forget
e(){
  echo "evaluating : $@"
  eval "$@" 1>/dev/null 2>&1 &
}

alias E=e #because to get to insert at the beginning, I use the "I", which use majuscule

ee(){ #execute a nohup onto the parameters
  set -x
  typeset name="$(echo "$*" | sed 's/[^a-zA-Z0-9]/_/g')"
  typeset filePath="$et/nohup/$name.nohup.out"
  mkdir -p "$(dirname "$filePath")"
  (
    echo "In path : $PWD"
    echo "Executing command : $@"
    echo "Begin date at : $(date +%Y%m%d_%H%M%S)"
  ) >> "$filePath"

  typeset cdpath="$PWD"
  (
    #TODO : trap "" 1 #catch the nohup signal
    nohup bash -l -c eval "$@" \; _ee_end "$filePath" >> "$filePath" 2>&1 &
  )
  tail -f "$filePath"
}

_ee_end(){ #to be used only by ee internal command
  typeset filePath="$1"
  (
    echo "End of the execution date : $(date %Y%m%d_%H%M%S)"
  ) >> "$filePath"
}



f(){ #<patterns> ...
  typeset patt
  while [[ $# -gt 0 ]]; do
    [[ -z "$patt" ]] && patt="($1)" || patt="$patt|($1)"
    shift
  done

  find . | g "$patt" #if we want it faster, use plain find
}
g(){ #[-v] <pattern> [<files>]
  typeset v
  [[ "$1" = "-v" ]] && v="-v" && shift

  typeset i
  typeset min="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
  [[ "$1" = "$min" ]] && i="-i"

  egrep $v $i --color "$1"
}
gv(){ #<pattern> [<files>]
  g -v "$@"
}
#alias h=
#alias i=
#alias j=
alias k="smartKill --list"
alias kk="smartKill --kill"
alias kw="smartKill --window"
alias l='$LS'
alias m=git
#alias n=
o(){
  case "$env_type" in
    win) cygstart "${@:-.}" ;;
  lux) gnome-open "${@:-.}" ;;
#lux) kde-open "${@:-.}" ;; #for that, look into the DESKTOP_SESSION value
    mac) open "${@:-.}" ;;
  *) echo "Your environment is not defined";;
esac
}
alias p="profile_utils_dirqueue" #push a
alias q=exit
r(){
  while [[ $# -gt 0 ]]; do
    typeset f="$1" ; shift
    if [[ -d "$f" ]]; then
      rmdir -p -v -- "$f"
    else
      rm -v -- "$f"
    fi
  done
}
alias rr='rm -rf --'
alias s=shell                                  #s = launch a new shell
t(){
  [[ $# -gt 0 ]] && shortcut_t_setted_prog="$(args_toEvaluatedVar "$@")"
  eval "${shortcut_t_setted_prog:-./launch.bash}"
}
#alias u=
w(){ profile_utils_watch "${@:-l}" ; } #watch, l by default
#alias v=
alias x=smartchx
#alias y=
#alias z=

alias tf='tail -f'
alias cp='scp -r'

alias 0n="tr '\0' '\n'"
alias n0="tr '\n' '\0'"


alias ll='l -ahtr' #if it's not l we want, it's ll
lc(){ ls "$@" | wc -l ; } #count number of files
#TODO why it bug : lt(){ l | tail $1 ; } #l with tail
llt(){ ll | tail $1 ; } #ll with tail

fg(){ find . -type f -print0 | xargs -0 egrep --color -i "$1" ; }

lg(){ l | g "$@" ; }
lgv(){ l | gv "$@$" ; }

alias pl='dirs -p -l'

alias ep=profile_editor_editInPath

alias nastyNames="find . -name '*[^a-zA-Z0-9._-]*'"
TODO(){ find . -type f | xargs -n 100 grep -n TODO ; }

alias eof='touchext .eof'
alias EOF='touchext _EOF'

-(){ cd - ; l ; }
#because ?(){ echo "$*" | bc -l ; } crash the profile sometimesk
calcul(){ echo "$*" | bc -l ; }
alias ?=calcul


mc(){ #<msg ...> #git commit
  typeset msg="$*" branch="$(git rev-parse --abbrev-ref HEAD)"
  git pull origin "$branch" || return
  git commit -m "$msg"
  git push origin "$branch" || return
}
alias ms='m status'
alias ma='m add'
mp(){ #<branch> #git rebase
  typeset branch="origin/${1:-$(git rev-parse --abbrev-ref HEAD)}"
  m rebase "$branch"
}

md(){ git diff "$@"; }
save(){ #copy the path given to the same location + date
  typeset date="$(date +%Y%m%d_%H%M%S)"
  typeset path="${1%/}"
  echo "Creating ${path}_$date ..."
  \cp --archive "$path" "${path}_$date"
}

#Echo and then execute the command
excho(){ echo "$@" ; "$@" ; }

###########################
# change dir
###########################

#!/usr/bin/env bash

#test a command for parameters, if we can use them or not
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

#alias up to 10 level
#so i don't have to count when moving
alias ..='c ..'
alias ...='c ../..'
alias ....='c ../../..'
alias .....='c ../../../..'
alias ......='c ../../../../..'
alias .......='c ../../../../../..'
alias ........='c ../../../../../../..'
alias .........='c ../../../../../../../..'
alias ..........='c ../../../../../../../../..'
alias ...........='c ../../../../../../../../../..'

###########################
# Bigger aliases for less used commands
###########################

alias df='df -h'  #sizes in humain format
alias du='du -h'  #sizes in humain format
alias less='less -r'       # raw control characters
alias whence='type -a'     # where, of a sort
alias wget='wget --no-check-certificate'
alias man='man -a'
alias diff='diff -r'

alias ss='serv -c $conf/hosts.lst -s' #connect through ssh
alias sl='serv -c $conf/hosts.lst -l' #list all awailable servers
alias sf='serv -c $conf/hosts.lst -f' #connect through ftp

#TODO secure actions
#TODO http://stackoverflow.com/questions/7713021/recycle-bin-script-in-unix
#alias mv='trash --conf-file=$et/conf/trash --simulate-mv'
#alias cp='trash --conf-file=$et/conf/trash --simulate-cp'
#alias rm='trash --conf-file=$et/conf/trash --simulate-rm'
# it should use the stuff from operating system first

#####################
# Utils function
#####################

#create a custom watch so i can use my aliases
#Ctrl-c to quit
profile_utils_watch(){
  [[ "X$1" == "X-h" ]] && {
    echo "w [-x command to execute each time output change] [command to show and follow]"
    exit 1
  }
  typeset exe="date"
  [[ "X$1" == "X-x" ]] && { exe="$2" ; shift; shift ; }
  typeset new="$(eval $@)" old=""
  while true; do
    eval "$exe"
    echo "$new"
    old="$new"
    while [ "X$old" == "X$new" ]; do
      sleep 1
      new="$(eval $@)"
    done
  done
}


#configuration for pentadactyl
export PENTADACTYL_INIT=":source \"$conf/pentadactyl.conf\""

#__EOF__


#####################
# Check the environnement
#####################

case "$OSTYPE" in
  *cygwin*) export env_type=win  ;;
  *linux*)  export env_type=lux  ;;
  *darwin*) export env_type=mac  ;;
  *)        export env_type=what ;;
esac

base_app="$et/app/${env_type}_app"

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
    nodosfilewarning= #special for cygwin and dos paths
    ff_path="$base_app/firefox/App/Firefox/firefox.exe"
    ff_profile="$(cygpath -w "$ff_profile")"
    ;;
esac

alias firefox='"$ff_path" -profile "$ff_profile"'
alias ff='nohup "$ff_path" -profile "$ff_profile" >/dev/null 2>&1 &'


#####################
# Load the bin path if exists
#####################

[[ -f "$et/profile_local.bash" ]] && source "$et/profile_local.bash"

#####################
# Load the profile bash
#####################
email="$(str_lower `whoami`@`hostname`)"

source "$conf/local.bash"

case "${TYPE_ENV:-}" in
  dev) PS1_COLOR=`term_color fg_blue`;;
  prod) PS1_COLOR=`term_color fg_red`;;
  re7) PS1_COLOR=`term_color fg_green`;;
  *) PS1_COLOR="`term_color fg_red`!!! TYPE_ENV not set !!!`echo``term_color fg_red``term_color bg_yellow`" ;;
esac

export TYPE_ENV="${TYPE_ENV:-dont_know}"
export SCREEN_SIZE="${SCREEN_SIZE:-150x51}"

###########################
# Test program files (only if there is no config yet)
###########################

if [[ "${TYPE_ENV:-}" == dont_know ]]; then
  for cmd in $(sed 's/#.*$//g' "$conf/exe_exists.lst"); do
    which $cmd >/dev/null 2>&1 && continue
    echo "!!! $cmd is not found in this environment, you might whant to add it !!!"
  done
fi

#Git part
#export GIT_CONFIG="$conf/gitconfig git fetch --all"
if [[ ! -f "$HOME/.gitconfig" ]]; then
  cat "$conf/gitconfig" > "$HOME/.gitconfig"
fi

__git_ps1 () { # params
  typeset branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
  if [[ -n "$branch" ]]; then
    printf "$1" "$branch"
  fi
}


#. "$conf/git-completion-gilles"
. "$conf/git-completion.bash"






#bash variable sheet
# ${toto#reg} delete the shortest match from the left
# ${toto##reg} delete the longest match from the left
# ${toto%reg} delete the shortest from the right
# ${toto%%reg} delete the longest from the right
# ${toto:-lala} $toto or "lala"
# ${toto:=lala} $toto or toto="lala" ; $toto
# ${toto:+lala} $toto and "lala" or ""
# ${toto:?"lala"} $toto or echo "lala"





#__EOF__
