#!/usr/bin/env bash


local_lib_load_app(){ #<app path> <ref path>
  typeset app_path="$1"
  typeset base_path="$2"

  app_path=$(cd "$base_path" ; cygpath -ua "$app_path")
  "$app_path" 2>/dev/null >/dev/null &
}



local_lib_load(){ #<xml file>
  typeset xml_file="$1"
  typeset ref_dir=`dirname "$1"`

  cat $file_xml |\
    egrep '(<file name=)|(<path>)' |\
    cut -d'<' -f2- |\
    sed 's/\\/\\\\\\\\/g' |\
    gawk '{printf("%s%s",$0,(NR%2?":":"\n"))}' |\
    gawk '{
      split($0, arr_name, "\"")
      cur_name = tolower(arr_name[2])
      sub(/ |-/, "_", cur_name)
      split($0, arr_path, ">")
      split(arr_path[3], arr_path, "<")
      cur_path = arr_path[1]
      ref_dir="'$ref_dir'"
      fct_base="local_lib_load_app"
      printf("alias app%s=\"%s %s %s\"\n", cur_name, fct_base, cur_path, ref_dir)
    }'
}


#__EOF__
