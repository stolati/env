#!/usr/bin/env bash

###################
# Special FPGA search
###################

export PROJECT_FPGA_CLEARCASE="/cygdrive/m/mke_P_FPGA_WB_6_dev/FPGA_comp/FPGA_WB"
export PROJECT_FPGA_DEV="$HOME/FPGA_dev"
export PROJECT_FPGA_LIST="$HOME/tmp/FPGA/tclContent.lst"


#list of aliases for fpga (begin with fp)
fp(){
  echo "f => search vim"
  echo "l => search grep"
  echo "o => open (default main)"
  echo "g => git"
}
alias fpf="fpga_search vim"
alias fpl="fpga_search grep"
alias fpo="fpga_open"
alias fpg="fpga_git"


##############################
# FPGA Opening
##############################
fpga_open(){ #<cmd>
  case "${1:-main}" in
    open) #to be used internally
      script="$2"; shift; shift
      (
        export ATDM_UNIT=EPM
        export ATDMFPGA="$(cygpath -w "$PROJECT_FPGA_DEV")"
        export HOME="$HOME/tmp/FPGA"

        "$PROJECT_FPGA_DEV/libraries/insttcl_85/winnt/bin/wish.exe" "$(cygpath -w "$script")" "$@" >/dev/null 2>&1 &
      )
    ;;
    env_local) fpga_open open "$PROJECT_FPGA_DEV/set_env/set_env/set_env.tcl" -local 1 -lang english -ver 2.0 -atdmver 6.0 ;;
    env_net) fpga_open open "$PROJECT_FPGA_DEV/set_env/set_env/set_env.tcl" -lang english -ver 2.0 -atdmver 6.0 ;;
    main) fpga_open open "$PROJECT_FPGA_DEV/atdm/main/atdm.tcl" -envtype fpga ;;
    choose) fpga_open open "$PROJECT_FPGA_DEV/choice_project/project.tcl" -envtype fpga ;;
    create) fpga_open open "$PROJECT_FPGA_DEV/design_init/design_init/design_init.tcl" -envtype fpga ;;
    *) echo "!!! error command not known !!!"
       echo "fpga_open <cmd> => launch a fpga program"
       echo "  env_local => env setting (local)"
       echo "  env_net   => env setting (network)"
       echo "  main      => fpga main program"
       echo "  choose    => fpga choose project"
       echo "  create    => fpga create project"
    ;;
  esac
}


##############################
# FPGA Search
##############################

fpga_search(){ #<cmd>
  case "$1" in
    init)
      echo "initialising the fast search FPGA"
      rm -f "$PROJECT_FPGA_LIST"
      find "$PROJECT_FPGA_DEV" \( -name '*.tcl' -o -name '*.english' \)-print0 | xargs -0 fgrep -n '' > "$PROJECT_FPGA_LIST"
      echo "$(cut -d: -f1 "$PROJECT_FPGA_LIST" | uniq -d | wc -l) files searched"
    ;;
    grep)
      [[ -f "$PROJECT_FPGA_LIST" ]] || fpga_search init
      tosearch="$2"

      icase= #only search exatly when they is upper char in the search field
      [[ "$(echo "$tosearch" | tr '[:upper:]' '[:lower:]')" = "$tosearch" ]] && icase="--ignore-case"

      fgrep --no-filename $icase "$2" "$PROJECT_FPGA_LIST"
    ;;
    vim)
      (
        cd "$PROJECT_FPGA_DEV"
        fileList="$(fpga_search grep "$2" | cut -d: -f1 | sort -u)"
        $EDITOR "+ba" "+/$2" $fileList
      )
    ;;
    *) echo "!!! error command not known !!!"
       echo "fpga_search <cmd> => search into fpga project"
       echo "  init   => (re-)initiate the search file"
       echo "  grep   => grep in the project"
       echo "  vim    => launch a vim with each file found"
    ;;
  esac
}




##############################
# FPGA Search
##############################

fpga_git(){ #<command>
  case "$1" in
    rebase) #rebase ClearCase status
      cleartool.exe rebase -stream stream:mke_P_FPGA_WB_6_dev@\\HWB_pvob -recommended
    ;;
    pull) #remove the current dev path, put the new in place
      echo "!!! Rebase ClearCase !!!"
      fpga_git rebase

      echo "!!! Copying !!!"
      #think of the /D parameter of xcopy (copy only newer file)
      time cmd.exe /c xcopy /C /I /E /R /Q /Y "$(cygpath -w "$PROJECT_FPGA_CLEARCASE")" "$(cygpath -w "$PROJECT_FPGA_DEV")"

      echo "doing the search init"
      #fpga_search_init >/dev/null
    ;;
    push) #
      #git diff --no-prefix > patchfile
      #patch -p0 < patchfile
    ;;
    *) echo "!!! error command not known !!!"
       echo "fpga_git <cmd> => git simili command for fpga project"
       echo "  rebase => rebase the ClearCase view"
       echo "  pull   => reinitiate the local files"
       echo "  push   => nothing for the moment"
    ;;
  esac
}


#__EOF__
