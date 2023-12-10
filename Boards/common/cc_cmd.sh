tfa_cc_undirect_command=(
	CC_TFA_ARCH
	CC_TFA_PLAT
	CC_TFA_DEBUG
	CC_TFA_CFLAGS
	CC_TFA_LDFLAGS
)

tfa_cc_direct_command=(
	AARCH32_SP
	ARM_ARCH_MAJOR
	SPD
	DTB_FILE_NAME
	OPENSSL_DIR
	STM32MP_SDMMC
	STM32MP_DDR4_TYPE
	STM32MP_LPDDR4_TYPE
	TFA_EXTERNAL_DT
)

optee_cc_undirect_command=(
	CC_OPTEE_ARCH
	CC_OPTEE_PLATFORM
	CC_OPTEE_CFLAGS
	CC_OPTEE_LDFLAGS
	CC_OPTEE_LIBGCC_LOCATE_CFLAGS
	CC_OPTEE_CFLAGS32
)

optee_cc_direct_command=(
	CFG_ARM64_core
	CFG_TEE_CORE_DEBUG
	CFG_TEE_CORE_LOG_LEVEL
	CFG_SCMI_SCPFW
	CFG_SCP_FIRMWARE
	CFG_EMBED_DTB_SOURCE_FILE
	CFG_EXT_DTS
	CFG_STM32_CLK_DEBUG
)

uboot_command=(
	EXT_DTS
)

kernel_command=(
	LOADADDR
	KBUILD_EXTDTS
	KERNEL_BUILD_DIR
	W
	C
	CF
)

build_kernel_command=(
	KERNEL_DTB_FILES
	KERNEL_DEFCONFIG
	KERNEL_USER_MAKE_OPTIONS
	INSTALL_MOD_PATH
)

all_command_array=(
	${tfa_cc_undirect_command[@]}
	${tfa_cc_direct_command[@]}
	${optee_cc_undirect_command[@]}
	${optee_cc_direct_command[@]}
	${uboot_command[@]}
	${kernel_command[@]}
	${build_kernel_command[@]}
)


clean_all_cc_command()
{
	for var in ${all_command_array[@]}
	do
		unset "$var"
	done
}