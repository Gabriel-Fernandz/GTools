#!/bin/bash -

echo "Tfa build:"

CC_BUILD_DIR="../build/${CC_BOARD_BUILD}/tfa"

fip_dir=${CC_BUILD_DIR}/../fip
fip_tool="$fip_dir/fiptool"
fip_file="$fip_dir/$fip_name"

BL32=${fip_dir}/tee-header_v2.bin
BL32_EXTRA1=${fip_dir}/tee-pager_v2.bin
BL32_EXTRA2=${fip_dir}/tee-pageable_v2.bin
BL33=${fip_dir}/u-boot-nodtb.bin
BL33_CFG=${fip_dir}/u-boot.dtb

if test -z "$CC_BOARD_NAME"; then
	echo "CC_BOARD_NAME : NOT SET !!!"
	read
	exit 0
fi

if test "$TFA_EXTERNAL_DT"; then
	TFA_EXTERNAL_DT=$(realpath $TFA_EXTERNAL_DT)
fi

_var()
{
	for var in ${tfa_command[@]}
	do
		echo "$var=${!var} "
	done
}

_make()
{
	cmd="make "
	cmd+="-j $(nproc) "
	cmd+="BUILD_PLAT=${CC_BUILD_DIR} "

	cmd+="${TFA_CC_ARCH} "

	for var in ${tfa_command[@]}
	do
		if [ -n "${!var}" ]; then
			cmd+="$var=${!var} "
		fi
	done

	cmd+=" $@"

	gexecute "$cmd"

	cmd+=" fip "

	if test "$AARCH32_SP" != "sp_min"; then
		cmd+=" bl31"
		cmd+=" BL32=${BL32} BL32_EXTRA1=${BL32_EXTRA1} BL32_EXTRA2=${BL32_EXTRA2}"
		# cmd+=" OPENSSL_DIR=$OECORE_NATIVE_SYSROOT/usr"
	else
		echo "SPMIN!!!!!!!!!!!"
	fi
	cmd+=" BL33=${BL33} BL33_CFG=${BL33_CFG}"

	gexecute "$cmd"
}

_clean()
{
	cmd="make KBUILD_OUTPUT=${CC_BUILD_DIR} clean distclean"

	gexecute "$cmd"
}

_rmbuild()
{
	if test -z "$CC_BUILD_DIR"; then
		echo "CC_BUILD_DIR=$CC_BUILD_DIR !!!!!!"
		exit 1
	fi

	cmd="rm -rf ${CC_BUILD_DIR}"
	gexecute "$cmd"
}

_install()
{
	tfa_filename=tf-a-${CC_BOARD_NAME}.stm32

	if  test "$tfa_filename" = ""; then
		echo tfa_filename=$tfa_filename !!!
		return
	fi

	gexecute "mkdir -p $fip_dir"

	gexecute "cp ./tools/fiptool/fiptool $fip_dir"
	gexecute "cp ${CC_BUILD_DIR}/$tfa_filename $fip_dir/$tfa_file"
	gexecute "cp ${CC_BUILD_DIR}/$fip_name $fip_dir"

}

_flash()
{
	flash_stm32 ${CC_BUILD_DIR}/../fip/$tfa_file
	flash_fip ${CC_BUILD_DIR}/../fip/$fip_name
}

_update_fip()
{
	echo nothing to do
}

_make_all()
{
	_make && _install && _update_fip
}

_all()
{
	mount_sdcard_and_wait $FIP &
	_make && _install && _update_fip && _flash && reset_board
}

eval _"$@"
