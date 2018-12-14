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

pentagram_b_chip_nand_config()
{
	XBOOT_CONFIG=q628_defconfig
	UBOOT_CONFIG=pentagram_sc7021_nand_b_defconfig
	KERNEL_CONFIG=pentagram_sc7021_bchip_emu_initramfs_defconfig
	CROSS_COMPILE=$1
	NEED_ISP=1
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" > $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
}
pentagram_b_chip_emmc_config()
{
	XBOOT_CONFIG=q628_defconfig
	UBOOT_CONFIG=pentagram_sc7021_emmc_b_defconfig
	KERNEL_CONFIG=pentagram_sc7021_bchip_emu_defconfig
	CROSS_COMPILE=$1
	NEED_ISP=1
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" > $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
}
pentagram_b_chip_nor_config()
{
	XBOOT_CONFIG=q628_defconfig
	UBOOT_CONFIG=pentagram_sc7021_romter_b_defconfig
	KERNEL_CONFIG=pentagram_sc7021_bchip_emu_initramfs_defconfig
	CROSS_COMPILE=$1
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" > $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
}
pentagram_a_chip_nand_config()
{
	XBOOT_CONFIG=q628_defconfig
	UBOOT_CONFIG=pentagram_sc7021_nand_defconfig
	KERNEL_CONFIG=pentagram_sc7021_achip_emu_initramfs_defconfig
	CROSS_COMPILE=$1
	NEED_ISP=1
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" > $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
}
pentagram_a_chip_emmc_config()
{
	XBOOT_CONFIG=q628_defconfig
	UBOOT_CONFIG=pentagram_sc7021_emmc_defconfig
	KERNEL_CONFIG=pentagram_sc7021_achip_emu_defconfig
	CROSS_COMPILE=$1
	NEED_ISP=1
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" > $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
}
pentagram_a_chip_nor_config()
{
	XBOOT_CONFIG=q628_defconfig
	UBOOT_CONFIG=pentagram_sc7021_romter_defconfig
	KERNEL_CONFIG=pentagram_sc7021_achip_emu_initramfs_defconfig
	CROSS_COMPILE=$1
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" > $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
}
pentagram_8388_b_chip_config()
{
	XBOOT_CONFIG=8388_defconfig
	UBOOT_CONFIG=pentagram_8388_b_defconfig
	KERNEL_CONFIG=pentagram_8388_bchip_defconfig
	CROSS_COMPILE=$1
	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" > $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
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
	find $UBOOT_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f -name "pentagram_*" | sort -i | sed "s,"$UBOOT_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t,] ,g" | sed "s,^ , [,g"
	$ECHO ""
	read UBOOT_CONFIG_NUM
	if [ -z $UBOOT_CONFIG_NUM ];then
		$ECHO $COLOR_RED"Error: Unknow config num!!"$COLOR_ORIGIN
		exit 1;
	fi
	UBOOT_CONFIG=$(find $UBOOT_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f -name "pentagram_*" | sort -i | sed "s,"$UBOOT_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t, ,g" | sed -n $UBOOT_CONFIG_NUM"p" | sed -r "s, +[0-9]* ,,g")

	$ECHO $COLOR_GREEN"Select kernel config :"$COLOR_ORIGIN
	$ECHO " ==============================================="
	find $KERNEL_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f -name "pentagram_*" | sort -i | sed "s,"$KERNEL_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t,] ,g" | sed "s,^ , [,g"
	$ECHO ""
	read KERNEL_CONFIG_NUM
	if [ -z $KERNEL_CONFIG_NUM ];then
		$ECHO $COLOR_RED"Error: Unknow config num!!"$COLOR_ORIGIN
		exit 1;
	fi
	KERNEL_CONFIG=$(find $KERNEL_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f -name "pentagram_*" | sort -i | sed "s,"$KERNEL_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t, ,g" | sed -n $KERNEL_CONFIG_NUM"p" | sed -r "s, +[0-9]* ,,g")

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

	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" > $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
	if [ $NEED_ISP = '1' ];then
		echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
	fi
	if [ $ZEBU_RUN = '1' ];then
		echo "ZEBU_RUN="$ZEBU_RUN >> $BUILD_CONFIG
	fi
}

$ECHO $COLOR_GREEN"Q628 configs."$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[1] Pentagram B chip (EMMC)"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[2] Pentagram B chip (SPI-NAND)"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[3] Pentagram B chip (NOR/romter)"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[4] Pentagram A chip (EMMC)"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[5] Pentagram A chip (SPI-NAND)"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[6] Pentagram A chip (NOR/romter)"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[7] 8388 B chip"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[8] others"$COLOR_ORIGIN
read num

case "$num" in
	1)
		pentagram_b_chip_emmc_config $1
		;;
	2)
		pentagram_b_chip_nand_config $1
		;;
	3)
		pentagram_b_chip_nor_config $1
		;;
	4)
		pentagram_a_chip_emmc_config $2
		;;
	5)
		pentagram_a_chip_nand_config $2
		;;
	6)
		pentagram_a_chip_nor_config $2
		;;
	7)
		pentagram_8388_b_chip_config $1
		;;
	8)
		others_config $1 $2
		;;
	*)
		echo "Error: Unknow config!!"
		exit 1
esac
