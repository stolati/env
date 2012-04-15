#!/usr/bin/env bash

###################
# Special FPGA search
###################

export PROJECT_FPGA_HOME="/cygdrive/d/applications/3p/fpga_wb/fpga_wb_6.0"
export PROJECT_FPGA_LIST="$HOME/.tclContent.lst"

#initialise the fpga stuff
fpga_init(){ #nothing
  rm -f "$PROJECT_FPGA_LIST"
  echo "initialising the fast search FPGA, take a cofee"
  find "$PROJECT_FPGA_HOME" -name '*.tcl' -print0 | xargs -0 fgrep -n '' > "$PROJECT_FPGA_LIST"
  echo "done"
}

fpga_grep(){ #<stuff to grep>
  [[ -f "$PROJECT_FPGA_LIST" ]] || fpga_init
  fgrep --no-filename "$1" "$PROJECT_FPGA_LIST" | g "$1"
}

tg(){ #<stuff to grep> #thales grep and launch vim on it
  cd "$PROJECT_FPGA_HOME"
  $EDITOR "+v/$1/d" "$PROJECT_FPGA_LIST"
}

###################
# Special FPGA launch
###################

#TODO puts open=cygstart in profile if win
#fpga_launch(){
#  #needed variables
#  export FPGA_CONF="$(cygpath -a -w "/cygdrive/d/users/meite/fpga_conf")"
#  export ATDMFPGA="$(cygpath -a -w "$PROJECT_FPGA_HOME")"
#  export ATDMUNIT="EPM"
#
#  typeset launch_in="$PROJECT_FPGA_HOME/choice_project"
#  typeset tcl_bin="$PROJECT_FPGA_HOME/libraries/insttcl_85/winnt/bin/choose_project.exe"
#  typeset choice_path="$PROJECT_FPGA_HOME/choice_project/project.tcl"
#
#  typeset tcl_bin="$(cygpath -a -w "$tcl_bin")"
#  typeset choice_path="$(cygpath -a -w "$choice_path")"
#
#  echo cygstart --directory="$launch_in" "$tcl_bin" "$choice_path" -envtype fpga
#  cygstart --directory="$launch_in" "$tcl_bin" "$choice_path" -envtype fpga
#}


#__EOF__
