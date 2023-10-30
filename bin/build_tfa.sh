#!/bin/bash -

echo "Tfa build:"

echo SDK=$SDK
source $SDK
# unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS MACHINE LD_LIBRARY_PATH

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

. cc_cmd_make.sh

_var()
{
	display_cc_command ${tfa_cc_undirect_command[@]}
	echo
	display_cc_command ${tfa_cc_direct_command[@]}
}

_make()
{
	cmd="make "
	cmd+="-j $(nproc) "
	cmd+="BUILD_PLAT=${CC_BUILD_DIR} "

	make_cc_undirect_command ${tfa_cc_undirect_command[@]}

	make_cc_direct_command ${tfa_cc_direct_command[@]}

	# cmd+="${TFA_CC_ARCH} "

	# for var in ${tfa_command[@]}
	# do
	# 	if [ -n "${!var}" ]; then
	# 		cmd+="$var=${!var} "
	# 	fi
	# done

	cmd+=" $@"

	g_execute.sh "$cmd"

	cmd+=" fip "

	if test "$AARCH32_SP" != "sp_min"; then
		cmd+=" bl31"
		cmd+=" BL32=${BL32} BL32_EXTRA1=${BL32_EXTRA1} BL32_EXTRA2=${BL32_EXTRA2}"
		# cmd+=" OPENSSL_DIR=$OECORE_NATIVE_SYSROOT/usr"
	else
		echo "SPMIN!!!!!!!!!!!"
	fi
	cmd+=" BL33=${BL33} BL33_CFG=${BL33_CFG}"

	g_execute.sh "$cmd"
}

_clean()
{
	cmd="make KBUILD_OUTPUT=${CC_BUILD_DIR} clean distclean"

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
	tfa_filename=tf-a-${CC_BOARD_NAME}.stm32

	if  test "$tfa_filename" = ""; then
		echo tfa_filename=$tfa_filename !!!
		return
	fi

	g_execute.sh "mkdir -p $fip_dir"

	g_execute.sh "cp ./tools/fiptool/fiptool $fip_dir"
	g_execute.sh "cp ${CC_BUILD_DIR}/$tfa_filename $fip_dir/$tfa_file"
	g_execute.sh "cp ${CC_BUILD_DIR}/$fip_name $fip_dir"

}

_flash()
{
	g_board flash_stm32 ${CC_BUILD_DIR}/../fip/$tfa_file
	g_board flash_fip ${CC_BUILD_DIR}/../fip/$fip_name
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
	g_board mount_sdcard_and_wait $FIP & disown %1
	_make && _install && _update_fip && _flash && g_board reset
}

