#!/usr/bin/env bash
set -eux

#####################
# Init configuration
#####################
export JAVA_HOME="$bin/jdk1.7.0_09"
export PATH="$JAVA_HOME/bin:$PATH"
export JVM_ARGS="-Xms1024m -Xmx1024m -Xmx1024m -XX:MaxPermSize=256m -XX:PermSize=64M"

#####################
# Link to executable
#####################
java="$JAVA_HOME/bin/java"
eclipse="$bin/eclipse/eclipse"
squirrel="$bin/squirrel-sql/squirrel-sql.sh"
jackrabbit="$bin/jackrabbit/jackrabbit-standalone-2.4.3.jar"

workspace="$et/workspace"
m2="$et/.m2"
eclipseConf="$et/.eclipse"


#####################
# Configuration
#####################
in_memory=true #false
copy_each="$(expr '10*60')" #each 10 minutes
stop_file="$et/mem_stop_file"

#local link = value ; original files = ${value}_ori ; mem content = /tmp/.../$value
files=$(cat <<EOF
$(dirname "$eclipse")
$(dirname "$JAVA_HOME")
$m2
$workspace
$eclipseConf
EOF
)

size="1G"
rampath="/tmp/ramdisk_$RANDOM"


#####################
# Utils functions
#####################

#path is the path of the directory
mem_conf2path(){ #conf
	echo "$conf"
}

#ori is the path where the original path data will be stored
mem_conf2ori(){ #<conf>
	typeset conf="$1"
	echo "${conf}_ori"
}

#mem is the path in the ram disk directory
mem_conf2mem(){ #<conf> <mem_path>
	typeset conf="$1" mem_path="$2"
	echo "$mem_path/$(basename "$conf")"
}

lauchNforget(){ #command param1 ...
	$@ 2>/dev/null 1>/dev/null &
}

#####################
# mem functions
#####################

#initialise all the stuff
mem_open(){ #conf_list rampath size
	typeset conf_list="$1" rampath="$2" size="$3"
	
	#creating the mem path
	ramdisk "$size" "$rampath"

	#copy the mem and make tests
	echo "$conf_list" | while read conf; do
		path="$(mem_conf2path "$conf")"
		ori="$(mem_conf2ori "$conf")"
		mem="$(mem_conf2mem "$conf")"

		[[ -d "$path" ]] || exit
		[[ ! -e "$mem" ]] || exit
		[[ ! -e "$ori" ]] || exit
		cp --archive "$path" "$mem"
	done

	#link the mem
	echo "$conf_list" | while read conf; do
		path="$(mem_conf2path "$conf")"
		ori="$(mem_conf2ori "$conf")"
		mem="$(mem_conf2mem "$conf")"

		mv "$path" "$ori" #move the path to ori
		ln -s "$mem" "$path" #link the path to mem
	done
}


#clean the stuff
mem_close(){ #conf_list rampath size
	typeset conf_list="$1" rampath="$2" size="$3"
	
	#be sure to be syncronised before removing stuff
	mem_refresh "$conf_list" "$rampath" "$size"

	#unpopulate and clean
	echo "$conf_list" | while read conf; do
		path="$(mem_conf2path "$conf")"
		ori="$(mem_conf2ori "$conf")"
		mem="$(mem_conf2mem "$conf")"

		rm "$path" #remove the link
		mv "$ori" "$path" #move the path back from ori
	done
}


#syncronized it, in case of power failure you will have the ori directory
mem_refresh(){ #conf_list rampath size
	typeset conf_list="$1" rampath="$2" size="$3"
	echo "$conf_list" | while read conf; do
		path="$(mem_conf2path "$conf")"
		ori="$(mem_conf2ori "$conf")"
		mem="$(mem_conf2mem "$conf")"
		
		cp --archive --update --no-target-directory "$mem" "$ori"
	done
}


#####################
# mem loop function
#####################

start_memory(){ #conf_list rampath size copy_each stop_file
	typeset conf_list="$1" rampath="$2" size="$3" copy_each="$4" stop_file="$5"

	mem_open "$conf_list" "$rampath" "$size"

	typeset t=0
	while [[ ! -f "$stop_file" ]]; do #the only stop case is the stop file
		typeset t="$(( (t + 1) % copy_each ))" #loop from 0 to copy_each
		[[ "$t" -eq 0 ]] && mem_refresh "$conf_list" "$rampath" "$size"
		sleep 1
	done
	
	rm "$stop_file"
	mem_close "$conf_list" "$rampath" "$size"
}

stop_memory(){ #conf_list rampath size copy_each stop_file
	typeset conf_list="$1" rampath="$2" size="$3" copy_each="$4" stop_file="$5"
	touch "$stop_file"
}


#####################
# execute the functions we need
#####################

$in_memory && start_memory "$conf_list" "$rampath" "$size" "$copy_each" "$stop_file"

echo "launching eclipse"
lauchNforget "$eclipse"

echo "lauching squirrel"
lauchNforget "$squirrel"

echo "launching jackrabbit"
(
  cd "$et/jackrabbit_data"
  "$java" -jar "$jackrabbit" -p 8081
)

$in_memory && stop_memory "$conf_list" "$rampath" "$size" "$copy_each" "$stop_file"

echo "It ends well"


