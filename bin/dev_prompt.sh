#!/bin/bash

gdebug_prompt=""
if [ "$gdebug" == "true" ]; then
	gdebug_prompt="(debug) "
fi

ps1_login_and_machin='\[\033[00;35m\]\u@\h:'
ps1_path='\[\033[00;36m\]\w'
ps1_branch='\[\033[1;35m\]$(__git_ps1)\n'
# ps1_gprompt='\W'_$1
ps1_gprompt=$1/'\W'
ps1_newline="\[\033[0;35m\]└─ \[\033[1;34m\] $gdebug_prompt$ps1_gprompt \[\033[0;35m\]\$ \[\033[0m\]"

export PS1="$ps1_login_and_machin $ps1_path $ps1_branch $ps1_newline"