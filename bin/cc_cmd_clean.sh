source $GTOOLS_PATH/Boards/common/cc_cmd.sh

for var in ${all_command_array[@]}
do
	# echo unset "$var"
	unset "$var"
done