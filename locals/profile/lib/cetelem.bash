#!/usr/bin/env bash

case "`whoami`@`hostname`" in
  *@bernay) TYPE_ENV=re7 ;;
  *@hermes) TYPE_ENV=prod ;;
  *@cofinoga-rec ) TYPE_ENV=re7 ;;
  *@cofinoga) TYPE_ENV=prod ;;
  *) echo "env not known" ;;
esac


alias eof='touchext .eof'
alias EOF='touchext _EOF'


#printnet

printnet_name="$(ls ~/sbin/pnserver.* 2>/dev/null | grep -v sh | cut -d. -f2)"

print_start(){ ~/sbin/pnserver.sh $printnet_name start ; }
print_stop(){ ~/sbin/pnserver.sh $printnet_name stop ; }
print_restart(){ ~/sbin/pnserver.sh $printnet_name restart ; }
print_status(){ ~/sbin/pnserver.sh $printnet_name status ; }

eval "$(_proAliasPath /data/printnet_cetelem/ print)"
eval "$(_proAliasPath /app/printnet_cetelem/ print)"

#cft
eval "$(_proAliasPath /data/cft cft)"
eval "$(_proAliasPath /apps/cft cft)"

#apmx
eval "$(_proAliasPath /app/apmx/config)"
eval "$(_proAliasPath /app/apmx/config/run/pitney)"
eval "$(_proAliasPath /data-apmx/apm_files)"
eval "$(_proAliasPath /app/apmx/scripts)"
eval "$(_proAliasPath /data/dialogue/data dia)"
eval "$(_proAliasPath /data/dialogue/output dia)"

save(){
  typeset f="$1"
  if [ ! -f "$f" ]; then
    echo "file [$f] not existing"
    return
  fi

  typeset g="$(dirname $f)/Archives/$(basename $f).$(date +%Y_%m_%d)"
  mkdir -p $(dirname $f)/Archives
  echo cp "$f" "$g"
  cp "$f" "$g"
}

#__EOF__
