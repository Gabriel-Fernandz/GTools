#! /bin/bash

enter_uboot_cfg="/local/home/$USER/.enter_uboot.cfg"

mmc="mmc0"
serial_port=/dev/ttyACM0
usb_port=/dev/ttyUSB0

if [ -f "$enter_uboot_cfg" ] ; then
	mmc=`cat $enter_uboot_cfg`
fi

ums0_mmc="ums0_$mmc"

echo ums0_mmc = $ums0_mmc

libsmount="/media/$USER/bootfs";
# libsmount="/media/$USER/userfs";

smount="/media/$USER/bootfs";
lockdir=/tmp/uboot.lock

if [ -f  "$lockdir" ]; then
	rm $lockdir
fi



function reset_board()
{
	#
	#/usr/local/bin/openocd -s /usr/local/share/openocd/scripts -f board/stm32mp15x_ev1_stlink_swd.cfg -c init -c reset -c shutdown
	#stty -F $serial_port 9600
	#echo -ne '\0' > $serial_port

	python -c 'import termios; termios.tcsendbreak(3, 0)' 3>/dev/ttyACM0
}

function ums0_mmc0()
{
	/usr/local/bin/openocd -s /usr/local/share/openocd/scripts -f board/stm32mp15x_ev1_stlink_swd.cfg -c ums0_mmc0 -c reset -c shutdown
}

function ums0_mmc1()
{
	/usr/local/bin/openocd -s /usr/local/share/openocd/scripts -f board/stm32mp15x_ev1_stlink_swd.cfg -c ums0_mmc1 -c reset -c shutdown
}


function ums0_mmc()
{
	echo "****** /usr/local/bin/openocd -s /usr/local/share/openocd/scripts -f board/stm32mp15x_ev1_stlink_swd.cfg -c $ums0_mmc -c reset -c shutdown"
	/usr/local/bin/openocd -s /usr/local/share/openocd/scripts -f board/stm32mp15x_ev1_stlink_swd.cfg -c "$ums0_mmc" -c reset -c shutdown
	
}


function mount_sdcard()
{
	# echo "@Mount SD CARD/EMMC from uboot...222222222"

	test=1
	
	echo Waiting Uboot ! reset the board

	while : ; do
		# echo Waiting Uboot ! reset the board
		echo "ums 0 mmc 0" > $serial_port
		# echo "ums 0 mmc 0" > $usb_port
		sleep 0.5
		
		partname=`lsblk -r -o NAME,PARTLABEL,MOUNTPOINT | grep rootfs |  cut -d ' ' -f1`

		if [[ ! $partname == "" ]]; then
			/usr/bin/udisksctl mount -b /dev/disk/by-partlabel/bootfs
			break;
		fi

	done

	sleep 0.5
	
	touch $lockdir

}

function mount_sdcard_old()
{
	echo "@Mount SD CARD/EMMC from uboot...222222222"

	test=1

	while [ $test -eq 1 ]; do
		echo Waiting Uboot ! reset the board
		echo "ums 0 mmc 0" > $serial_port

		sleep 0.5
		mountpoint -q $libsmount
		test=$?
	done

	touch $lockdir

}

mountpoint -q $libsmount
if [ $? -eq 0 ]; then
	echo "Already mounted !"
	touch $lockdir
	sleep 2
else
	reset_board

	# ums0_mmc
# workaround

	mount_sdcard
fi

return 0


