#!/bin/bash -

CC_BUILD_DIR="../build/${CC_BOARD_BUILD}/optee"

fip_dir=${CC_BUILD_DIR}/../fip
fip_tool="$fip_dir/fiptool"
fip_file="$fip_dir/$fip_name"

bl32=${CC_BUILD_DIR}/core/tee-header_v2.bin
bl32_extra1=${CC_BUILD_DIR}/core/tee-pager_v2.bin
bl32_extra2=${CC_BUILD_DIR}/core/tee-pageable_v2.bin

source /home/frq07381/myWorkspace/GTools/Boards/common/optee_cmd

echo DSK=$SDK

source $SDK

unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS MACHINE LD_LIBRARY_PATH

echo CFG_SCMI_SCPFW=$CFG_SCMI_SCPFW 

echo "ouuu ${optee_command[@]}"

if test -z "$CC_BOARD_NAME"; then
	echo "CC_BOARD_NAME : NOT SET !!!"
	read
	exit 0
fi

unset CFG_EXT_DTS
unset CFG_SCP_FIRMWARE

export CROSS_COMPILE64=$CROSS_COMPILE

# if test "$CFG_EXT_DTS"; then
# 	CFG_EXT_DTS=$(realpath $CFG_EXT_DTS)
# fi

# if test "$CFG_SCP_FIRMWARE"; then
# 	CFG_SCP_FIRMWARE=$(realpath $CFG_SCP_FIRMWARE)
# fi

_var()
{
	echo optee var
	echo ${optee_command[@]}

	for var in ${optee_command[@]}
	do
		echo "$var=${!var} "
	done
}

_make()
{

	cmd="make "

	cmd+="-j $(nproc) "
	cmd+="O=${CC_BUILD_DIR} "
	cmd+="$OPTEE_CC_ARCH "

	for var in ${optee_command[@]}
	do
		if [ -n "${!var}" ]; then
			cmd+="$var=${!var} "
		fi
	done

	cmd+=" $@"
	cmd=`eval echo $cmd`

	g_execute.sh "$cmd"
}

_rmbuild()
{
	if test -z "$CC_BUILD_DIR"; then
		echo "CC_BUILD_DIR=$CC_BUILD_DIR !!!!!!"
		exit 1
	fi

	cmd="rm -rf ${CC_BUILD_DIR}"
	g_execute.sh "$cmd"
}

_install()
{
	g_execute.sh "mkdir -p $fip_dir"

	g_execute.sh "cp $bl32 $fip_dir"
	g_execute.sh "cp $bl32_extra1 $fip_dir"
	g_execute.sh "cp $bl32_extra2 $fip_dir"
}

_update_fip()
{
	echo fiptool=$fiptool

	g_execute.sh "$fip_tool --verbose update --tos-fw $bl32 $fip_file"
	g_execute.sh "$fip_tool --verbose update --tos-fw-extra1 $bl32_extra1 $fip_file"
	g_execute.sh "$fip_tool --verbose update --tos-fw-extra2 $bl32_extra2 $fip_file"
}

_flash()
{
	flash_fip ${CC_BUILD_DIR}/../fip/$fip_name
}

_make_all()
{
	_make && _install && _update_fip
}

_all()
{
	mount_sdcard_and_wait $FIP & disown %1
	_make && _install && _update_fip && _flash && reset_board
}

_checkpatch()
{
	source scripts/checkpatch.sh
}

_who()
{
	echo "optee"
}

# echo "$@"
# eval _"$@"
