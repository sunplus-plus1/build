#!/bin/bash
COLOR_RED="\033[0;1;31;40m"
COLOR_GREEN="\033[0;1;32;40m"
COLOR_YELLOW="\033[0;1;33;40m"
COLOR_ORIGIN="\033[0m"
ECHO="echo -e"
BUILD_CONFIG=./.config

XBOOT_CONFIG_ROOT=./boot/xboot/configs
UBOOT_CONFIG_ROOT=./boot/uboot/configs
KERNEL_CONFIG_ROOT=./linux/kernel/arch/arm/configs

p_chip_nand_config()
{
	if [ "$2" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	else
		XBOOT_CONFIG=q628_Rev2_SPINAND_defconfig
	fi
	UBOOT_CONFIG=sp7021_nand_p_defconfig
	KERNEL_CONFIG=sp7021_chipP_emu_nand_defconfig
	CROSS_COMPILE=$1
	NEED_ISP=1
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=v5" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
	echo "BOOT_FROM=NAND" >> $BUILD_CONFIG
}

p_chip_emmc_config()
{
	if [ "$2" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	else
		XBOOT_CONFIG=q628_Rev2_EMMC_defconfig
	fi
	UBOOT_CONFIG=sp7021_emmc_p_defconfig
	KERNEL_CONFIG=sp7021_chipP_emu_defconfig
	CROSS_COMPILE=$1
	NEED_ISP=1
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=v5" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
	echo "BOOT_FROM=EMMC" >> $BUILD_CONFIG
}

p_chip_nor_config()
{
	if [ "$2" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	else
		XBOOT_CONFIG=q628_Rev2_EMMC_defconfig
	fi
	UBOOT_CONFIG=sp7021_romter_p_defconfig
	KERNEL_CONFIG=sp7021_chipP_emu_initramfs_defconfig
	CROSS_COMPILE=$1
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=v5" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
	echo "BOOT_FROM=SPINOR" >> $BUILD_CONFIG
}

p_chip_sdcard_config()
{
	if [ "$2" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	else
		XBOOT_CONFIG=q628_Rev2_EMMC_defconfig
	fi
	UBOOT_CONFIG=sp7021_emmc_p_defconfig
	KERNEL_CONFIG=sp7021_chipP_emu_defconfig
	CROSS_COMPILE=$1
	NEED_ISP=1
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=v5" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
	echo "BOOT_FROM=SDCARD" >> $BUILD_CONFIG
}

p_chip_tftp_config()
{
	if [ "$2" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	else
		XBOOT_CONFIG=q628_Rev2_EMMC_defconfig
	fi
	UBOOT_CONFIG=sp7021_romter_p_defconfig
	KERNEL_CONFIG=sp7021_chipP_emu_initramfs_defconfig
	CROSS_COMPILE=$1
	BOOT_KERNEL_FROM_TFTP=1
	echo "Please enter TFTP server IP address: (Default is 172.18.12.62)"
	read TFTP_SERVER_IP
	if [ "${TFTP_SERVER_IP}" == "" ]; then
		TFTP_SERVER_IP=172.18.12.62
	fi
	echo "TFTP server IP address is ${TFTP_SERVER_IP}"
	echo "Please enter TFTP server path: (Default is /home/scftp)"
	read TFTP_SERVER_PATH
	if [ "${TFTP_SERVER_PATH}" == "" ]; then
		TFTP_SERVER_PATH=/home/scftp
	fi
	echo "TFTP server path is ${TFTP_SERVER_PATH}"
	echo "Please enter board MAC address:"
	read BOARD_MAC_ADDR
	USER_NAME=$(whoami)
	echo "Your USER_NAME is ${USER_NAME}"
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=v5" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
	echo "BOOT_KERNEL_FROM_TFTP="${BOOT_KERNEL_FROM_TFTP} >> ${BUILD_CONFIG}
	echo "USER_NAME=_"${USER_NAME} >> ${BUILD_CONFIG}
	echo "BOARD_MAC_ADDR="${BOARD_MAC_ADDR} >> ${BUILD_CONFIG}
	echo "TFTP_SERVER_IP="${TFTP_SERVER_IP} >> ${BUILD_CONFIG}
	echo "TFTP_SERVER_PATH="${TFTP_SERVER_PATH} >> ${BUILD_CONFIG}
}

p_chip_usb_config()
{
	if [ "$2" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	else
		XBOOT_CONFIG=q628_Rev2_EMMC_defconfig
	fi
	UBOOT_CONFIG=sp7021_romter_p_defconfig
	KERNEL_CONFIG=sp7021_chipP_emu_initramfs_defconfig
	CROSS_COMPILE=$1
	NEED_ISP=1
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=v5" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
	echo "BOOT_FROM=USB" >> $BUILD_CONFIG
}

c_chip_nand_config()
{
	if [ "$2" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	else
		XBOOT_CONFIG=q628_Rev2_SPINAND_defconfig
	fi
	UBOOT_CONFIG=sp7021_nand_c_defconfig
	KERNEL_CONFIG=sp7021_chipC_emu_nand_defconfig
	CROSS_COMPILE=$1
	NEED_ISP=1
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=v7" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
	echo "BOOT_FROM=NAND" >> $BUILD_CONFIG
}

c_chip_emmc_config()
{
	if [ "$2" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	else
		XBOOT_CONFIG=q628_Rev2_EMMC_defconfig
	fi
	UBOOT_CONFIG=sp7021_emmc_c_defconfig
	KERNEL_CONFIG=sp7021_chipC_emu_defconfig
	CROSS_COMPILE=$1
	NEED_ISP=1
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=v7" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
	echo "BOOT_FROM=EMMC" >> $BUILD_CONFIG
}

c_chip_nor_config()
{
	if [ "$2" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	else
		XBOOT_CONFIG=q628_Rev2_EMMC_defconfig
	fi
	UBOOT_CONFIG=sp7021_romter_c_defconfig
	KERNEL_CONFIG=sp7021_chipC_emu_initramfs_defconfig
	CROSS_COMPILE=$1
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=v7" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
	echo "BOOT_FROM=SPINOR" >> $BUILD_CONFIG
}

c_chip_sdcard_config()
{
	if [ "$2" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	else
		XBOOT_CONFIG=q628_Rev2_EMMC_defconfig
	fi
	UBOOT_CONFIG=sp7021_emmc_c_defconfig
	KERNEL_CONFIG=sp7021_chipC_emu_defconfig
	CROSS_COMPILE=$1
	NEED_ISP=1
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=v7" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
	echo "BOOT_FROM=SDCARD" >> $BUILD_CONFIG
}

c_chip_tftp_config()
{
	if [ "$2" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	else
		XBOOT_CONFIG=q628_Rev2_EMMC_defconfig
	fi
	UBOOT_CONFIG=sp7021_romter_c_defconfig
	KERNEL_CONFIG=sp7021_chipC_emu_initramfs_defconfig
	CROSS_COMPILE=$1
	BOOT_KERNEL_FROM_TFTP=1
	echo "Please enter TFTP server IP address: (Default is 172.18.12.62)"
	read TFTP_SERVER_IP
	if [ "${TFTP_SERVER_IP}" == "" ]; then
		TFTP_SERVER_IP=172.18.12.62
	fi
	echo "TFTP server IP address is ${TFTP_SERVER_IP}"
	echo "Please enter TFTP server path: (Default is /home/scftp)"
	read TFTP_SERVER_PATH
	if [ "${TFTP_SERVER_PATH}" == "" ]; then
		TFTP_SERVER_PATH=/home/scftp
	fi
	echo "TFTP server path is ${TFTP_SERVER_PATH}"
	echo "Please enter MAC address of target board (ex: 00:22:60:00:88:20):"
	echo "(Press Enter directly if you want to use board's default MAC address.)"
	read BOARD_MAC_ADDR
	if [ "${BOARD_MAC_ADDR}" != "" ]; then
		echo "MAC address of target board is ${BOARD_MAC_ADDR}"
	fi
	USER_NAME=$(whoami)
	echo "Your USER_NAME is ${USER_NAME}"
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=v7" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="${CROSS_COMPILE} >> $BUILD_CONFIG
	echo "BOOT_KERNEL_FROM_TFTP="${BOOT_KERNEL_FROM_TFTP} >> ${BUILD_CONFIG}
	echo "USER_NAME=_"${USER_NAME} >> ${BUILD_CONFIG}
	echo "BOARD_MAC_ADDR="${BOARD_MAC_ADDR} >> ${BUILD_CONFIG}
	echo "TFTP_SERVER_IP="${TFTP_SERVER_IP} >> ${BUILD_CONFIG}
	echo "TFTP_SERVER_PATH="${TFTP_SERVER_PATH} >> ${BUILD_CONFIG}
}

c_chip_usb_config()
{
	if [ "$2" = "revA" ];then
		XBOOT_CONFIG=q628_defconfig
	else
		XBOOT_CONFIG=q628_Rev2_EMMC_defconfig
	fi
	UBOOT_CONFIG=sp7021_romter_c_defconfig
	KERNEL_CONFIG=sp7021_chipC_emu_initramfs_defconfig
	CROSS_COMPILE=$1
	NEED_ISP=1
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=v7" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
	echo "BOOT_FROM=USB" >> $BUILD_CONFIG
}

others_config()
{
	$ECHO $COLOR_GREEN"Initial all configs."$COLOR_ORIGIN

	$ECHO $COLOR_GREEN"Select xboot config :"$COLOR_ORIGIN
	$ECHO " ==============================================="
	find $XBOOT_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f -name "*_defconfig" | sort -i | sed "s,"$XBOOT_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t,] ,g" | sed "s,^ , [,g"
	$ECHO ""
	read XBOOT_CONFIG_NUM
	if [ -z $XBOOT_CONFIG_NUM ];then
		$ECHO $COLOR_RED"Error: Unknow config num!!"$COLOR_ORIGIN
		exit 1;
	fi
	XBOOT_CONFIG=$(find $XBOOT_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f  -name "*_defconfig" | sort -i | sed "s,"$XBOOT_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t, ,g" | sed -n $XBOOT_CONFIG_NUM"p" | sed -r "s, +[0-9]* ,,g")

	$ECHO $COLOR_GREEN"Select uboot config :"$COLOR_ORIGIN
	$ECHO " ==============================================="
	find $UBOOT_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f -name "*" | sort -i | sed "s,"$UBOOT_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t,] ,g" | sed "s,^ , [,g"
	$ECHO ""
	read UBOOT_CONFIG_NUM
	if [ -z $UBOOT_CONFIG_NUM ];then
		$ECHO $COLOR_RED"Error: Unknow config num!!"$COLOR_ORIGIN
		exit 1;
	fi
	UBOOT_CONFIG=$(find $UBOOT_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f -name "*" | sort -i | sed "s,"$UBOOT_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t, ,g" | sed -n $UBOOT_CONFIG_NUM"p" | sed -r "s, +[0-9]* ,,g")

	$ECHO $COLOR_GREEN"Select kernel config :"$COLOR_ORIGIN
	$ECHO " ==============================================="
	find $KERNEL_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f -name "*" | sort -i | sed "s,"$KERNEL_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t,] ,g" | sed "s,^ , [,g"
	$ECHO ""
	read KERNEL_CONFIG_NUM
	if [ -z $KERNEL_CONFIG_NUM ];then
		$ECHO $COLOR_RED"Error: Unknow config num!!"$COLOR_ORIGIN
		exit 1;
	fi
	KERNEL_CONFIG=$(find $KERNEL_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f -name "*" | sort -i | sed "s,"$KERNEL_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t, ,g" | sed -n $KERNEL_CONFIG_NUM"p" | sed -r "s, +[0-9]* ,,g")

	$ECHO $COLOR_GREEN"Select rootfs config :"$COLOR_ORIGIN
	$ECHO " ==============================================="
	$ECHO " [1] v5"
	$ECHO " [2] v7"
	$ECHO " ==============================================="
	read ROOTFS_CONFIG_NUM
	if [ $ROOTFS_CONFIG_NUM = '1' ];then
		ROOTFS_CONFIG=v5
	elif [ $ROOTFS_CONFIG_NUM = '2' ];then
		ROOTFS_CONFIG=v7
	fi

	$ECHO $COLOR_GREEN"Select compiler config :"$COLOR_ORIGIN
	$ECHO " ==============================================="
	$ECHO " [1] v5"
	$ECHO " [2] v7"
	$ECHO " ==============================================="
	read COMPILER_CONFIG_NUM
	if [ $COMPILER_CONFIG_NUM = '1' ];then
		CROSS_COMPILE=$1
	elif [ $COMPILER_CONFIG_NUM = '2' ];then
		CROSS_COMPILE=$2
	fi

	$ECHO $COLOR_GREEN"Need isp?"$COLOR_ORIGIN
	$ECHO " ==============================================="
	$ECHO " y/n"
	$ECHO " ==============================================="
	read NEED_ISP_CONFIG
	if [ $NEED_ISP_CONFIG = 'y' ];then
		NEED_ISP=1
	elif [ $NEED_ISP_CONFIG = 'n' ];then
		NEED_ISP=0
	fi

	$ECHO $COLOR_GREEN"Zebu run?"$COLOR_ORIGIN
	$ECHO " ==============================================="
	$ECHO " y/n"
	$ECHO " ==============================================="
	read NEED_ZEBU_RUN
	if [ $NEED_ZEBU_RUN = 'y' ];then
		ZEBU_RUN=1
	elif [ $NEED_ZEBU_RUN = 'n' ];then
		ZEBU_RUN=0
	fi

	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=${ROOTFS_CONFIG}" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
	if [ $NEED_ISP = '1' ];then
		echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
	fi
	if [ $ZEBU_RUN = '1' ];then
		echo "ZEBU_RUN="$ZEBU_RUN >> $BUILD_CONFIG
	fi
}

$ECHO $COLOR_GREEN"Select boards:"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[1] SP7021 Ev Board"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[2] SP7021 Demo Board (V1/V2)"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[3] SP7021 Demo Board (V3)"$COLOR_ORIGIN
read board

if [ "$board" = "1" ];then
	echo "LINUX_DTB=sp7021-ev" > $BUILD_CONFIG
elif [ "$board" = "2" ];then
	echo "LINUX_DTB=sp7021-demov2" > $BUILD_CONFIG
elif [ "$board" = "3" ];then
	echo "LINUX_DTB=sp7021-demov3" > $BUILD_CONFIG
else
	echo "Error: Unknow board!!"
	exit 1
fi

chip=0

$ECHO $COLOR_GREEN"Select chip."$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[1] Chip C"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[2] Chip P"$COLOR_ORIGIN
read chip

num1=0
num2=6

if [ "$chip" = "2" ];then
	$ECHO $COLOR_GREEN"Select configs (P chip)."$COLOR_ORIGIN
	$ECHO $COLOR_YELLOW"[1] eMMC"$COLOR_ORIGIN
	$ECHO $COLOR_YELLOW"[2] SPI-NAND"$COLOR_ORIGIN
	$ECHO $COLOR_YELLOW"[3] NOR/Romter"$COLOR_ORIGIN
	$ECHO $COLOR_YELLOW"[4] SD Card"$COLOR_ORIGIN
	$ECHO $COLOR_YELLOW"[5] TFTP server"$COLOR_ORIGIN
	$ECHO $COLOR_YELLOW"[6] USB"$COLOR_ORIGIN
	read num2
elif [ "$chip" = "1" ];then
	$ECHO $COLOR_GREEN"Select configs (C chip)."$COLOR_ORIGIN
	$ECHO $COLOR_YELLOW"[1] eMMC"$COLOR_ORIGIN
	$ECHO $COLOR_YELLOW"[2] SPI-NAND"$COLOR_ORIGIN
	$ECHO $COLOR_YELLOW"[3] NOR/Romter"$COLOR_ORIGIN
	$ECHO $COLOR_YELLOW"[4] SD Card"$COLOR_ORIGIN
	$ECHO $COLOR_YELLOW"[5] TFTP server"$COLOR_ORIGIN
	$ECHO $COLOR_YELLOW"[6] USB"$COLOR_ORIGIN
	$ECHO $COLOR_YELLOW"[7] others"$COLOR_ORIGIN
	read num1
else
	echo "Error: Unknow chip!!"
	exit 1
fi

num=`expr $num1 + $num2`
echo "select "$num
case "$num" in
	1)
		p_chip_emmc_config $1 revB
		;;
	2)
		p_chip_nand_config $1 revB
		;;
	3)
		p_chip_nor_config $1 revB
		;;
	4)
		p_chip_sdcard_config $1 revB
		;;
	5)
		p_chip_tftp_config $1 revB
		;;
	6)
		p_chip_usb_config $1 revB
		;;
	7)
		c_chip_emmc_config $2 revB
		;;
	8)
		c_chip_nand_config $2 revB
		;;
	9)
		c_chip_nor_config $2 revB
		;;
	10)
		c_chip_sdcard_config $2 revB
		;;
	11)
		c_chip_tftp_config $2 revB
		;;
	12)
		c_chip_usb_config $2 revB
		;;
	13)
		others_config $1 $2
		;;
	*)
		echo "Error: Unknow config!!"
		exit 1
esac
