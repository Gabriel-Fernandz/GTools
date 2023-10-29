#!/bin/bash -

echo "U-boot build:"

CC_BUILD_DIR="../build/${CC_BOARD_BUILD}/uboot"

fip_dir=${CC_BUILD_DIR}/../fip
fip_tool="$fip_dir/fiptool"
fip_file="$fip_dir/$fip_name"

uboot_bin=${CC_BUILD_DIR}/u-boot.bin
uboot_nodtb=${CC_BUILD_DIR}/u-boot-nodtb.bin
uboot_dtb=${CC_BUILD_DIR}/u-boot.dtb

if test -z "$CC_BOARD_NAME"; then
	echo "CC_BOARD_NAME : NOT SET !!!"
	read
	exit 0
fi

if test "$EXT_DTS"; then
	EXT_DTS=$(realpath $EXT_DTS)
fi

echo DSK=$SDK

source $SDK

unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS MACHINE LD_LIBRARY_PATH


_var()
{
	for var in ${uboot_command[@]}
	do
		echo "$var=${!var} "
	done
}

_defconfig()
{
	cmd="make KBUILD_OUTPUT=${CC_BUILD_DIR} ${UBOOT_DEFCONFIG}"

	cmd+="$@ "
	cmd=`eval echo $cmd`

	g_execute.sh "$cmd"
}

_make()
{
	cmd="make "
	cmd+="-j $(nproc) "
	cmd+="KBUILD_OUTPUT=${CC_BUILD_DIR} "
	cmd+="${UBOOT_DEVICE_TREE} "

	for var in ${uboot_command[@]}
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

	g_execute.sh "cp $uboot_bin $fip_dir"
	g_execute.sh "cp $uboot_nodtb $fip_dir"
	g_execute.sh "cp $uboot_dtb $fip_dir"
}

_update_fip()
{
	g_execute.sh "$fip_tool --verbose update --nt-fw $uboot_nodtb --hw-config $uboot_dtb $fip_file"
}

_make_all()
{
	_defconfig && _make && _install && _update_fip
}

_flash()
{
	flash_fip ${CC_BUILD_DIR}/../fip/$fip_name
}

_all()
{
	mount_sdcard_and_wait $FIP &
	_make && _install && _update_fip && _flash && reset_board
}

# eval _$@

