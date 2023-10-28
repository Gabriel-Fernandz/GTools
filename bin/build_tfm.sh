#!/bin/bash -

echo "TFM build: NOT TESTED !!!!!!!!!!!!!!!!!!!!!!!!!!"

CC_BUILD_DIR="../build/${CC_BOARD_NAME}/tfm"

if test -z "$CC_BOARD_NAME"; then
	echo "CC_BOARD_NAME : NOT SET !!!"
	read
	exit 0
fi

# $ cmake -S <SRC_DIRECTORY> -B <BUILD_DIRECTORY> \
#         -DTFM_PLATFORM=stm/stm32mp257f_ev \
#         -DTFM_TOOLCHAIN_FILE=toolchain_GNUARM.cmake \
#         -DTFM_PROFILE=profile_small \
#         -DCMAKE_BUILD_TYPE=debug
# $ make  -C <BUILD_DIRECTORY> install
	# cmd+=" -DTFM_PROFILE=profile_small"




export TFM_BUILD='/local/home/frq07381/views/mp25/ev1/build/stm32mp257f-ev1-revB/tfm'
export OPENOCD_BUILD='/local/home/frq07381/myWorkspace/Tools/openocd'
export BOARD_ENV='/local/home/frq07381/myWorkspace/Tools'
export CMSIS_SVD='/local/home/frq07381/myWorkspace/Tools/STM32MP25_v0r6'
export TOOLCHAIN_PATH='/local/cross_compile/gcc-arm-11.2-2022.02-x86_64-arm-none-eabi/bin'



export CC_PATH='/local/cross_compile/gcc-arm-11.2-2022.02-x86_64-arm-none-eabi/bin'
export PATH="${CC_PATH}":${PATHBACKUP}

TFM_CC_CROSS_COMPILE='arm-none-eabi'
# TFM_CC_CROSS_COMPILE='arm-ostl-linux-gnueabi'

# echo SDK=$SDK_TFM
# source $SDK

# echo CROSS_COMPILE$$CROSS_COMPILE

unset LD_LIBRARY_PATH
unset LDFLAGS
unset CFLAGS

_cmake()
{
	cmd="cmake"

	cmd+=" -S ."
	cmd+=" -B ${CC_BUILD_DIR}"
	cmd+=" -DCROSS_COMPILE=${TFM_CC_CROSS_COMPILE}"
	cmd+=" -DTFM_PLATFORM=${TFM_CC_TFM_PLATFORM}"
	cmd+=" -DTFM_TOOLCHAIN_FILE=toolchain_GNUARM.cmake"
	# cmd+=" -DTFM_PROFILE=profile_medium"
	cmd+=" -DTFM_PROFILE=profile_small"
	cmd+=" -DCMAKE_BUILD_TYPE=debug"
	cmd+=" -DTEST_S=ON"
	# cmd+=" -DTEST_S=ON -DTEST_NS=ON"
	echo cmd=$cmd

	gexecute "$cmd"
}

_cmake-gui()
{
	cmd="cmake-gui"

	cmd+=" -S ."
	cmd+=" -B ${CC_BUILD_DIR}"
	cmd+=" -DCROSS_COMPILE=${TFM_CC_CROSS_COMPILE}"
	cmd+=" -DTFM_PLATFORM=${TFM_CC_TFM_PLATFORM}"
	cmd+=" -DTFM_TOOLCHAIN_FILE=toolchain_GNUARM.cmake"
	# cmd+=" -DTFM_PROFILE=profile_medium"
	cmd+=" -DTFM_PROFILE=profile_small"
	cmd+=" -DCMAKE_BUILD_TYPE=debug"
	cmd+=" -DTEST_S=ON"
	# cmd+=" -DTEST_S=ON -DTEST_NS=ON"
	echo cmd=$cmd

	gexecute "$cmd"
}

_make()
{
	cmd="make"

	cmd+=" -C ${CC_BUILD_DIR} install"

	gexecute "$cmd"
}

_strip()
{
	cmd="arm-none-eabi-objcopy -S ${CC_BUILD_DIR}/bin/tfm_s.elf ${CC_BUILD_DIR}/../fip/tfm_s.elf.strip"
	gexecute "$cmd"

	cmd="arm-none-eabi-objcopy -S ${CC_BUILD_DIR}/bin/tfm_ns.elf ${CC_BUILD_DIR}/../fip/tfm_ns.elf.strip"
	gexecute "$cmd"
	cmd="../optee/scripts/sign_rproc_fw.py sign --in ${CC_BUILD_DIR}/../fip/tfm_s.elf.strip --in ${CC_BUILD_DIR}/../fip/tfm_ns.elf.strip --out ${CC_BUILD_DIR}/../fip/rproc_tfm_s_ns_sign.stm32 --key ../optee/keys/default_rproc.pem --plat-tlv SBOOTADDR 0x80000000"
	gexecute "$cmd"
}

_flash_firmware()
{

	/usr/bin/udisksctl mount -b /dev/disk/by-partlabel/rootfs
	partlabel="rootfs"

	echo "Wait : $partlabel"
	wait_mount $partlabel

 	firmware_file="${CC_BUILD_DIR}/../fip/rproc_tfm_s_ns_sign.stm32"

	echo firmware_file=$firmware_file

	if [[ $firmware_file == "" ]]; then
		echo file missing !!! firmware_file=$firmware_file !!
		return
	fi

	secret=`cat ~/.unix_secret`

	dest="/media/$USER/rootfs/lib/firmware/"

	if [ $dest ]; then
		sshpass -p $secret sudo cp $firmware_file $dest
		# sshpass -p $secret sudo cp -r $CC_BUILD_DIR/install_artifact_valid/lib/modules/* /media/$USER/rootfs/lib/modules/
	#	sshpass -p $secret sudo cp -r /tmp/install_artifact_valid/lib/modules/* /media/$USER/rootfs/lib/modules/
		sync
#		gumount
	else
		echo "!!!! destination doesn't exist !!!!"
	fi

	/bin/sync
}

_clean()
{
	echo todo

	cmd="rm -rf ${CC_BUILD_DIR}"
	gexecute "$cmd"

	cmd="git clean -dfx"
	gexecute "$cmd"
}

_all()
{
	_cmake
	_make
}

_openocd()
{
	# openocd -d2 -f /local/home/frq07381/myWorkspace/myBoard/gdb/openocd_stm32_m33.cfg
	openocd -d2 -f board/stm32mp25x_dk.cfg
}

_gdb()
{
	# arm-none-eabi-gdb -x /local/home/frq07381/myWorkspace/myBoard/gdb/cortex_m33_copro.gdb
	arm-none-eabi-gdb -x /local/home/frq07381/myWorkspace/Tools/cortex_m33_copro.gdb 
}

_puncover()
{
	puncover --elf_file ${CC_BUILD_DIR}/bin/tfm_s.elf
}

_edit()
{
	# code /local/home/frq07381/myWorkspace/myBoard/bin/build_tfm.sh
	echo "Nom du script $0"
	echo "premier paramètre $1"
	echo "second paramètre $2"
	echo "PID du shell " $$
	echo "code de retour $?"}
}


_help()
{
	echo "make"
	echo "cmake"
	echo "cmake"
	echo "clean"
	echo "flash_firmware"
	echo ""
}

for cmd in "$@"
do
	echo _$cmd
	eval _$cmd
done
