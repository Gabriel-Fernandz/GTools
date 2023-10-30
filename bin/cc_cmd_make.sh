

source $GTOOLS_PATH/Boards/common/cc_cmd.sh

make_cc_direct_command()
{
	for var in ${@}
	do
		if [ -n "${!var}" ]; then
			cmd+="$var=${!var} "
		fi
	done
}

make_cc_undirect_command()
{
	echo ${@}

	for var in ${@}
	do
		if [ -n "${!var}" ]; then
			cmd+="${!var} "
		fi
	done
}

display_cc_command()
{
	for var in ${@}
	do
		if [ -n "${!var}" ]; then
			# cmd+="$var=${!var} "
			echo "$var=${!var} "
		fi
	done
}
