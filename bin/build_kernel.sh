#!/bin/bash -


# To build (with SDK or ARM aarch64 Toolchain):

# make distclean
# make defconfig fragment-01-defconfig-cleanup.config fragment-02-defconfig-addons.config fragment-03-defconfig-cleanup-valid.config fragment-04-defconfig-addons-valid.config
# make W=1 -j$(nproc) all dtbs
# make INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH="$PWD/install_artifact_valid" modules_install
# rm install_artifact_valid/lib/modules/*/build 
#  rm install_artifact_valid/lib/modules/*/source

# Binaries:
# sudo cp arch/arm64/boot/dts/st/stm32mp2*.dtb /media/$USER/bootfs/
# sudo cp arch/arm64/boot/Image.gz /media/$USER/bootfs/
# sudo cp -r install_artifact_valid/lib/modules/* /media/$USER/rootfs/lib/modules/

echo "Linux build:"

CC_BUILD_DIR="../build/${PLATFORM}/kernel"

if test -z "$CC_BOARD_NAME"; then
	echo "CC_BOARD_NAME : NOT SET !!!"
	read
	exit 0
fi

if test "$KERNEL_BUILD_DIR"; then
	CC_BUILD_DIR=$KERNEL_BUILD_DIR
fi

if test "$KBUILD_EXTDTS"; then
	KBUILD_EXTDTS=$(realpath $KBUILD_EXTDTS)
fi

_var()
{
	for var in ${kernel_command[@]}
	do
		echo "$var=${!var} "
	done

	for var in ${build_kernel_command[@]}
	do
		echo "$var=${!var} "
	done
}

__make()
{
	cmd="make "
	cmd+="-j $(nproc) "
	cmd+="O=${CC_BUILD_DIR} "

	for var in ${kernel_command[@]}
	do
		if [ -n "${!var}" ]; then
			cmd+="$var=${!var} "
		fi
	done

	cmd=`eval echo $cmd`
}

_defconfig()
{
	cmd="make"
	cmd+=" O=${CC_BUILD_DIR}"
	cmd+=" ARCH=${ARCH} "
	cmd+=" defconfig ${KERNEL_DEFCONFIG} "

	gexecute "$cmd"
}

_menuconfig()
{
	cmd="make"
	cmd+=" O=${CC_BUILD_DIR}"
	cmd+=" ARCH=${ARCH} "
	cmd+=" menuconfig"

	gexecute "$cmd"
}

_savedefconfig()
{
	cmd="make"
	cmd+=" O=${CC_BUILD_DIR}"
	cmd+=" ARCH=${ARCH} "
	cmd+=" savedefconfig"

	gexecute "$cmd"

        gexecute "cp ${CC_BUILD_DIR}/defconfig arch/$ARCH/configs/$(echo ${DEFCONFIG} | cut -d' ' -f1)"
}


_make()
{
	__make

	if [ $# -eq 0 ]; then
		cmd+=" $KERNEL_USER_MAKE_OPTIONS"
	else
		cmd+=" $@"
	fi

	gexecute "$cmd"
}

_clean()
{
	cmd="make clean distclean"

	gexecute "$cmd"
}

_modules()
{
	__make
	# cmd+=" INSTALL_MOD_PATH=${INSTALL_MOD_PATH}"

	cmd+=" modules"

	gexecute "$cmd"
}

_install()
{
	# __make

	# cmd+=" INSTALL_MOD_STRIP=1"
	# cmd+=" INSTALL_MOD_PATH=${INSTALL_MOD_PATH}"
	# cmd+=" modules_install"

	# gexecute "$cmd"

	gexecute "rm ${CC_BUILD_DIR}/${INSTALL_MOD_PATH}/lib/modules/*/build"
	gexecute "rm ${CC_BUILD_DIR}/${INSTALL_MOD_PATH}/lib/modules/*/source"

}

_all()
{
	__make

	cmd+=" all dtbs modules"

	gexecute "$cmd"
}

_flash()
{
	devname=/dev/disk/by-partlabel/bootfs

	wait_mount bootfs

	dtb_file=${CC_BUILD_DIR}/${KERNEL_DTB_FILES}
	image_file=${CC_BUILD_DIR}/${KERNEL_IMAGE_FILE}

	echo dtb_file=$dtb_file
	echo image_file=$image_file

	if [[ $dtb_file == "" ]]; then
		echo dtb_file=$dtb_file !!
		return
	fi
	if [[ $image_file == "" ]]; then
		echo image_file=$image_file !!
		return
	fi

	secret=`cat ~/.unix_secret`

	dest="/media/$USER/bootfs"

	if [ $dest ]; then
		sshpass -p $secret sudo cp $dtb_file $dest
		sshpass -p $secret sudo cp $image_file $dest

		if  test "$1" = "modules"; then
			sshpass -p $secret sudo cp -r ${CC_BUILD_DIR}/${INSTALL_MOD_PATH}/lib/modules/* /media/$USER/rootfs/lib/modules/
		fi
		sync
	else
		echo "!!!! destination doesn't exist !!!!"
	fi

	/bin/sync
}

_all_old()
{
	# cmd="make"
	# cmd+=" -j $(nproc)"
	# cmd+=" O=${CC_BUILD_DIR}"
	# cmd+=" ARCH=${ARCH} "
	# cmd+=" CROSS_COMPILE=${CROSS_COMPILE}"
	# cmd+=" ${KERNEL_LOADADDR}"
	# cmd+=" all dtbs modules"

	# gexecute "$cmd"
	# _make
	# _flash

	# mount_sdcard_and_wait bootfs & disown %1

	# _make && _flash && reset_board


	_make && mount_sdcard_and_wait bootfs && _flash && reset_board
}

_go_build()
{
	pushd $PWD
	cd $CC_BUILD_DIR
}

_pop()
{
	popd
}

eval _"$@"
