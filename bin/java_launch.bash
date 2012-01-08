#/usr/bin/env bash

#special java case for cygwin

args_toEvaluatedVar(){ #args ...
  while [[ $# -ne 0 ]]; do
    printf '%s' "\"$(echo "$1" | sed 's/"/\\"/g')\" "
    shift
  done
  echo
}

if [[ "$env_type" != win ]]; then
  java "$@"
  return
fi

cmd="java"
while [[ $# -ne 0 ]]; do
  cmd="$cmd $(printf '%s' "\"$(cygpath -w -- "$1" | sed 's/"/\\"/g')\"")"
  shift
done

eval "$cmd"

#__EOF__
