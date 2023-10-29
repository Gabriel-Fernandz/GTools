#!/bin/bash

gdebug="false"

pause()
{
	if [ "$F9" == 1 ]; then
		read
	fi
}

if [ "$1" == "--ask" ]; then
	shift
	echo $@
	echo "(execute ?)"
	read
else
	echo $@
fi

if [ "$gdebug" == "false" ]; then
	$@
	if [ $? -ne 0 ]; then
		pause
		exit 1
	fi
fi

exit 0