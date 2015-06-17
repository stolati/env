#!/usr/bin/env bash

#can define stuffs :
# TYPE_ENV=dev|prod|re7|error
# SCREEN_SIZE=${height}x${width}

# or other stuff if needed

case "$email" in

  robert@robert-parallels-virtual-platform) # linux under virtual machine
    TYPE_ENV=dev
    export JAVA_HOME=~/bin/jdk1.8.0_45
    export JDK_HOME=~/bin/jdk1.8.0_45
    alias idea="ee ~/bin/idea-IU-141.1010.3/bin/idea.sh"
  ;;

  mickaelkerbrat@mickaels-macbook-pro.local) # My mac, yahoo
    TYPE_ENV=dev
    wcrun(){
      cd ~/projects/WebComment
      activator run -Dhttps.port=9443
    }

    mac_animations(){ # start|stop
      typeset action="$1"

      case "$action" in
        start)
          defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool YES
          defaults delete com.apple.dock expose-animation-duration
          defaults delete com.apple.dock springboard-show-duration
          defaults delete com.apple.dock springboard-hide-duration
          killall Dock
          ;;
        stop)
          defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool NO
          defaults write com.apple.dock expose-animation-duration -int 0
          defaults write com.apple.dock springboard-show-duration -int 0
          defaults write com.apple.dock springboard-hide-duration -int 0
          killall Dock
          ;;
        *)
          echo "mac_animations [start|stop]" >&2
          echo "name '$action' not known" >&2
          echo "exit without doing anything !" >&2
          ;;
      esac
    }

    mac_animations stop

  ;;

  #################
  # Cetelem informations
  ################
  #kerbratm@wxp05816) #cetelem computer
  #  export http_proxy="172.18.234.15:3128" #from http://intranet.ctlmcof.fr/config/proxy.pac
  #  TYPE_ENV=dev
  #  SCREEN_SIZE=198x71
  #;;
  #apmx@hermes|cft@hermes|printnet@hermes)
  #  . "$conf/lib/cetelem.bash"
  #  TYPE_ENV=prod
  #;;
  #apmx@bernay|cft@bernay|printnet@bernay)
  #  . "$conf/lib/cetelem.bash"
  #  TYPE_ENV=re7
  #;;
  #apmx@cofinoga-rec|cft@cofinoga-rec|printcof@cofinoga-rec)
  #  . "$conf/lib/cetelem.bash"
  #  TYPE_ENV=re7
  #;;
  #apmx@cofinoga|cft@cofinoga|printcof@cofinoga)
  #  . "$conf/lib/cetelem.bash"
  #  TYPE_ENV=prod
  #;;

esac

#__EOF__
