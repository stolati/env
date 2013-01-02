#!/usr/bin/env bash
SETX="set -eu"
$SETX

#####################
# Init configuration
#####################
export JAVA_HOME="$et/bin/jdk1.7.0_09"
#export JRE_HOME="$JAVA_HOME"
export PATH="$JAVA_HOME/bin:$PATH"
export JVM_ARGS="-Xms1024m -Xmx1024m -Xmx1024m -XX:MaxPermSize=256m -XX:PermSize=64M"

#####################
# Link to executable
#####################
java="$JAVA_HOME/bin/java"
eclipse="$et/bin/eclipse/eclipse"
squirrel="$et/bin/squirrel-sql/squirrel-sql.sh"
jackrabbit="$et/bin/jackrabbit/jackrabbit-standalone-2.4.3.jar"
jackrabbit_data="$et/jackrabbit_data"

workspace="$et/workspace"
m2="$et/.m2"
eclipseConf="$et/.eclipse"


#####################
# Configuration
#####################
in_memory=true #false
copy_each="$((10))" #each 10 minutes

#####################
# Utils functions
#####################

lauchNforget(){ $SETX #command param1 ...
	(
		$@ 2>/dev/null 1>/dev/null &
	) || true
}

#####################
# execute the functions we need
#####################


echo "launching eclipse"
lauchNforget "$eclipse"

echo "lauching squirrel"
lauchNforget "$squirrel"

echo "launching jackrabbit"
mkdir -p "$jackrabbit_data" || true
(
  cd "$jackrabbit_data"
  "$java" -jar "$jackrabbit" -p 8081
)

echo "It ends well"




