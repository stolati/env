#!/usr/bin/env bash
set -eu # TODO remove when dev

# order of installation :
# - local already exists
# - have the .ssh to get the github
# - clone with git
# - clone with svn
# - get the zip and unzip somewhere

# the cleaning should take that into account

echo "$@"

#############
# Constants
#############
if ${DEBUG:-false} ; then
    set -x
fi


#############
# Helper functions
#############

function __check_cmd(){
	typeset cmd="$1"
	which >/dev/null 2>&1
}




# From https://unix.stackexchange.com/questions/83926/how-to-download-a-file-using-just-bash-and-nothing-else-no-curl-wget-perl-et
function __wget() {
    : ${DEBUG:=0}
    local URL=$1
    local tag="Connection: close"
    local mark=0

    if [ -z "${URL}" ]; then
        printf "Usage: %s \"URL\" [e.g.: %s http://www.google.com/]" \
               "${FUNCNAME[0]}" "${FUNCNAME[0]}"
        return 1;
    fi
    read proto server path <<<$(echo ${URL//// })
    DOC=/${path// //}
    HOST=${server//:*}
    PORT=${server//*:}
    [[ x"${HOST}" == x"${PORT}" ]] && PORT=80
    [[ $DEBUG -eq 1 ]] && echo "HOST=$HOST"
    [[ $DEBUG -eq 1 ]] && echo "PORT=$PORT"
    [[ $DEBUG -eq 1 ]] && echo "DOC =$DOC"

    exec 3<>/dev/tcp/${HOST}/$PORT
    echo -en "GET ${DOC} HTTP/1.1\r\nHost: ${HOST}\r\n${tag}\r\n\r\n" >&3
    while read line; do
        [[ $mark -eq 1 ]] && echo $line
        if [[ "${line}" =~ "${tag}" ]]; then
            mark=1
        fi
    done <&3
    exec 3>&-
}


__url_load(){ set -eu
	typeset url="$1"
	if __check_cmd wget ; then # wget
		wget -O- "$url"
	elif __check_cmd curl ; then # curl
		curl "$url"
	elif __check_cmd nc ; then # netcal
		/usr/bin/printf 'GET / \n' | nc "$url" 80
	else 
		__wget "$url"
	fi
}




#############
# Begin of calculated variables
#############

current_file="$0"
current_dir="$(cd "$(dirname "$0")" ; pwd)"

case "$current_file" in
	bash) is_local=false ;;
	*/bash) is_local=false ;;
    *)  profile_path="$current_dir/profile.bash"
        [[ -f "$profile_path" ]] && is_local=true || is_local=false
esac

export CURRENT_SHELL=bash
if __check_cmd zsh ; then
    export CURRENT_SHELL=zsh
fi


if $is_local; then
    # the easy way, things are already downloaded
    export ENV_HOME_INSTALL="$current_dir"

    exec $CURRENT_SHELL --rcfile "$ENV_HOME_INSTALL/profile.bash"
    exit # just in case, and the code is more readable
fi





