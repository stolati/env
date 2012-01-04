#!/usr/bin/env bash

_proAliasCode(){ #<cmd> [<name>]
  typeset cmd="$1" name="${2:-$(basename "$1")}"
  name="$(echo "$name" | tr [:upper:] [:lower:])"
  echo "alias app$name='$cmd 2>&1 >/dev/null &'"
}

lux_app="$et/app/lux_app"

eval "$(_proAliasCode "$lux_app/eclipse/eclipse")"
eval "$(_proAliasCode "$lux_app/firefox/firefox")"
eval "$(_proAliasCode "$lux_app/pocket" lastpass)"
eval "$(_proAliasCode "java -jar \"$lux_app/minecraft.jar\"" minecraft)"
alias open=nautilus

unset lux_app

#__EOF__
