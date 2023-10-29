#!/bin/bash

export GTools_path=`git config --file=$HOME/.gtools.ini --get gtools.path`
export GTools_boards="$GTools_path/Boards"

g_tools_ini_file=$GTools_path/gtools.ini


conf_file='.conf'

gdebug="false"

tfa_file='tfa.stm32'
fip_name="fip.bin"

FIP="fip-a"

dev_prompt()
{
	gdebug_prompt=""
	if [ "$gdebug" == "true" ]; then
		gdebug_prompt="(debug) "
	fi

	ps1_login_and_machin='\[\033[00;35m\]\u@\h:'
	ps1_path='\[\033[00;36m\]\w'
	ps1_branch='\[\033[1;35m\]$(__git_ps1)\n'
	# ps1_gprompt='\W'_$1
	ps1_gprompt=$1/'\W'
	ps1_newline="\[\033[0;35m\]└─ \[\033[1;34m\] $gdebug_prompt$ps1_gprompt \[\033[0;35m\]\$ \[\033[0m\]"

	PS1="$ps1_login_and_machin $ps1_path $ps1_branch $ps1_newline"
}

pause()
{
	if [ "$F9" == 1 ]; then
		read
	fi
}

gexecute()
{
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
			return 1
		fi
	fi
}

g_debug()
{
	if [ "$gdebug" == "true" ]; then
		gdebug="false"
	else
		gdebug="true"
	fi

	dev_prompt $board
}

g_get_SDK()
{
	if [ -z "$1" ] || [ -z "$2" ]; then
		echo  "get_SDK <MP1 MP2> <path url>"
		return 1
	fi

	git config -f ${g_tools_ini_file} --get SDK.$1.$2
}

g_install_SDK()
{
	if [ -z "$1" ] || [ -z "$2" ]; then
		echo  "g_install_SDK <MP1 MP2> < path >"
		return 1
	fi
	echo
	echo

	sdk_url=`g_get_SDK $1 url`


	sdk_install_file=$(basename -a $sdk_url)
	rm /tmp/$sdk_install_file

	wget -P /tmp/ $sdk_url


	sdk_install_dir=`grep -a 'DEFAULT_INSTALL_DIR=\"\/' /tmp/$sdk_install_file`
	sdk_install_dir=`echo $sdk_install_dir | cut -d '"' -f2 | cut -d '/' -f4-`
	sdk_install_dir="$2/"${sdk_install_dir}


	sdk_install_file="/tmp/$sdk_install_file"
	echo $sdk_install_file

	chmod +x $sdk_install_file
#
	$sdk_install_file -y -d $sdk_install_dir

	path=`ls $sdk_install_dir/environment-setup-*`

	git config -f ${g_tools_ini_file} --add SDK.$1.path $path
}

function reset_board()
{
	python -c 'import termios; termios.tcsendbreak(3, 0)' 3>/dev/ttyACM0
}

function mount_sdcard_and_wait()
{
	serial_port=/dev/ttyACM0
	board_is_resting=0

	while : ; do

		partname=`lsblk -r -o NAME,PARTLABEL,MOUNTPOINT | grep $1 |  cut -d ' ' -f2`
		# echo partname=$partname
		if [[ $partname == "" ]]; then
			if [ "$board_is_resting" == 0 ]; then
				# echo reset the board
				board_is_resting=1
				reset_board
				sleep 2
			else
				echo "ums 0 mmc 0" > $serial_port
				sleep 0.5
			fi
		else
			# echo $1 is mounted
			break
		fi

	done

	board_is_resting=0

	sleep 0.5

}

function wait_mount()
{
	echo "Wait -->: $1"

	while : ; do
		partname=`lsblk -r -o NAME,PARTLABEL,MOUNTPOINT | grep $1 |  cut -d ' ' -f2`
		if [[ $partname != "" ]]; then
			break
		fi

		sleep 0.5

	done
}

function wait_mount_old()
{
	echo "Wait -->: $1"

	while : ; do
		if [ ! -e $1 ]; then
			sleep 0.5;
		else
			sleep 0.2;
			break;
		fi
	done
}

gpartition_gflash()
{
	devname=/dev/disk/by-partlabel/$1

	if ! test -f $2; then
		echo ""
		echo $2 doesnt exist !!!!!!!!
		echo ""
		return -1
	fi

	cmd="dd if=$2 of=$devname bs=1M conv=fdatasync"
	# echo $cmd

	wait_mount $1
	# mount_sdcard_and_wait $1

	gexecute $cmd

	/bin/sync
}

flash_stm32()
{
	file=${CC_BUILD_DIR}/../fip/$tfa_file

	file=$1

	case $PLATFORM in

	stm32mp1)
		FSBL="fsbl"
		;;
	stm32mp2)
		FSBL="fsbla"
		;;
	*)
		echo ""
		echo  PLATFORM=$PLATFORM doesnt exist !!!!!!!!
		echo ""
		return -1
	esac


	gpartition_gflash ${FSBL}1 $file
}

flash_fip()
{
	file=${CC_BUILD_DIR}/../fip/$fip_name
	file=$1

	gpartition_gflash "$FIP" $file
}

# g_flash()
# {
# 	flash_stm32
# 	flash_fip
# }

g_board()
{
	update_var

	gboards.py
	clear

	source $conf_file
}

save_current_dir()
{
	echo $PWD > /tmp/.gmake_dir
}

update_var()
{
	my_current_repo=`get_repo.py`
	# my_current_repo=$(basename $PWD) @@PP
}

git_push()
{
	update_var

	branch=`git config -f ${g_tools_ini_file} --get $my_current_repo.branch`
	topic=`git config -f ${g_tools_ini_file} --get $my_current_repo.topic`

	echo git push origin HEAD:refs/for/${branch}-${1}${topic}
}

git_push_dev()
{
	git_push dev
}

git_push_valid()
{
	git_push valid
}

git_checkout()
{
	update_var

	branch=`git config -f ${g_tools_ini_file} --get $my_current_repo.branch`

	echo git checkout ${branch}-${1}
}

git_checkout_dev()
{
	git_checkout dev
}

git_checkout_valid()
{
	git_checkout valid
}

export GTools_path=`git config --file=$HOME/.gtools.ini --get gtools.path`
export GTools_boards="$GTools_path/Boards"

# echo 0000000000000

if [ -e "$GTools_path/alias_gtools" ]; then
	# echo 111111111

	source $GTools_path/alias_gtools
fi
if [ -e "$GTools_path/alias_views" ]; then
	# echo 222222222222222
	source $GTools_path/alias_views
fi
