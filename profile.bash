#!/usr/bin/env bash
set -x

##################
# This is starting my environment
# THe information needed : 
#  - ENV_HOME_INSTALL => place where the env is installed
#  - CURRENT_SHELL => BASH or KSH
# 
# This should be executable by bash and ksh
###############

alias l='ls -l'

PS1="subbash > "

source "$ENV_HOME_INSTALL/titi.bash"



