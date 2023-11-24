#!/bin/bash
COLOR_RED="\033[0;1;31;40m"
COLOR_GREEN="\033[0;1;32;40m"
COLOR_YELLOW="\033[0;1;33;40m"
COLOR_ORIGIN="\033[0m"
ECHO="echo -e"
BUILD_CONFIG=./.config

XBOOT_CONFIG_ROOT=./boot/xboot/configs
UBOOT_CONFIG_ROOT=./boot/uboot/configs
KERNEL_ARM_CONFIG_ROOT=./linux/kernel/arch/arm/configs
KERNEL_RISCV_CONFIG_ROOT=./linux/kernel/arch/riscv/configs

UBOOT_CONFIG=
KERNEL_CONFIG=
BOOT_FROM=
XBOOT_CONFIG=

ARCH=arm

# bootdev=emmc
# bootdev=spi_nand
# bootdev=spi_nor
# bootdev=nor
# bootdev=tftp
# bootdev=usb
# bootdev=para_nand

bootdev_lookup()
{
	dev=$1
	if [ "$1" = "spi_nor" ]; then
		dev=nor
	elif [ "$1" = "nor" ]; then
		dev=romter
	elif [ "$1" = "spi_nand" ]; then
		dev=nand
	elif [ "$1" = "tftp" ]; then
		dev=romter
	elif [ "$1" = "para_nand" ]; then
		dev=pnand
	fi
	echo $dev
}

chip_lookup()
{
	chip=$1
	if [ "$1" = "1" ]; then
		chip=c
	elif [ "$1" = "2" ]; then
		chip=p
	fi
	echo $chip
}

xboot_defconfig_combine()
{
	# $1 => project
	# $2 => bootdev
	# $3 => c/p
	# $4 => board
	# $5 => zmem

	pid=$1
	chip=$3
	dev=$(bootdev_lookup $2)
	board=$4
	xzmem=$5
	defconfig=

	if [ "$board" = "zebu" ]; then
		if [ "$xzmem" = "1" ]; then
			defconfig=${pid}_${chip}_zmem_defconfig
		else
			defconfig=${pid}_${chip}_zebu_defconfig
		fi
	else
		defconfig=${pid}_${dev}_${chip}_defconfig
	fi
	echo $defconfig
}

uboot_defconfig_combine()
{
	# $1 => project
	# $2 => bootdev
	# $3 => c/p
	# $4 => board
	# $5 => zmem

	pid=$1
	dev=$(bootdev_lookup $2)
	chip=$3
	board=$4
	uzmem=$5
	defconfig=

	if [ "$board" = "zebu" ]; then
		if [ "$uzmem" = "1" ]; then
			defconfig=${pid}_${chip}_zmem_defconfig
		else
			defconfig=${pid}_${chip}_zebu_defconfig
		fi
	else
		defconfig=${pid}_${dev}_${chip}_defconfig
	fi

	echo $defconfig
}

linux_defconfig_combine()
{
	# $1 => project
	# $2 => bootdev
	# $3 => c/p
	# $4 => board

	pid=$1
	dev=$(bootdev_lookup $2)
	chip=$3
	board=$4
	defconfig=

	if [ "$4" = "zebu" ]; then
		defconfig=${pid}_${chip}_${board}_defconfig
	else
		defconfig=${pid}_${dev}_${chip}_${board}_defconfig
	fi

	echo $defconfig
}

set_uboot_config()
{
	if [ "$UBOOT_CONFIG" = "" ]; then
		UBOOT_CONFIG=$1
	fi
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
}

set_kernel_config()
{
	if [ "$KERNEL_CONFIG" = "" ]; then
		KERNEL_CONFIG=$1
	fi
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
}

set_bootfrom_config()
{
	if [ "$BOOT_FROM" = "" ]; then
		BOOT_FROM=$1
	fi
	echo "BOOT_FROM="$BOOT_FROM >> $BUILD_CONFIG
}

set_xboot_config()
{
	if [ "$XBOOT_CONFIG" = "" ]; then
		XBOOT_CONFIG=$1
	fi
	echo "XBOOT_CONFIG="$XBOOT_CONFIG >> $BUILD_CONFIG
}

p_chip_spi_nand_config()
{
	if [ "$1" = "revA" ]; then
		XBOOT_CONFIG=q628_defconfig
	fi

	set_xboot_config q628_Rev2_SPINAND_defconfig
	set_uboot_config sp7021_nand_p_defconfig
	set_kernel_config sp7021_chipP_emu_nand_defconfig
	set_bootfrom_config NAND

	NEED_ISP=1
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
}

p_chip_emmc_config()
{
	if [ "$1" = "revA" ]; then
		XBOOT_CONFIG=q628_defconfig
	fi

	set_xboot_config q628_Rev2_EMMC_defconfig
	set_uboot_config sp7021_emmc_p_defconfig
	set_kernel_config sp7021_chipP_emu_defconfig
	set_bootfrom_config EMMC

	NEED_ISP=1
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
}

p_chip_nor_config()
{
	if [ "$1" = "revA" ]; then
		XBOOT_CONFIG=q628_defconfig
	fi

	set_xboot_config q628_Rev2_EMMC_defconfig
	set_uboot_config sp7021_romter_p_defconfig
	set_kernel_config sp7021_chipP_emu_initramfs_defconfig
	set_bootfrom_config SPINOR
}

p_chip_tftp_config()
{
	if [ "$1" = "revA" ]; then
		XBOOT_CONFIG=q628_defconfig
	fi

	set_xboot_config q628_Rev2_EMMC_defconfig
	set_uboot_config sp7021_romter_p_defconfig
	set_kernel_config sp7021_chipP_emu_initramfs_defconfig

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
	set_uboot_config sp7021_romter_c_defconfig
	set_kernel_config sp7021_chipC_emu_initramfs_defconfig

	USER_NAME=$(whoami)
	echo "Your USER_NAME is ${USER_NAME}"
	echo "BOOT_KERNEL_FROM_TFTP="${BOOT_KERNEL_FROM_TFTP} >> ${BUILD_CONFIG}
	echo "USER_NAME=_"${USER_NAME} >> ${BUILD_CONFIG}
	echo "BOARD_MAC_ADDR="${BOARD_MAC_ADDR} >> ${BUILD_CONFIG}
	echo "TFTP_SERVER_IP="${TFTP_SERVER_IP} >> ${BUILD_CONFIG}
	echo "TFTP_SERVER_PATH="${TFTP_SERVER_PATH} >> ${BUILD_CONFIG}
}

p_chip_usb_config()
{
	if [ "$1" = "revA" ]; then
		XBOOT_CONFIG=q628_defconfig
	fi

	set_xboot_config q628_Rev2_EMMC_defconfig
	set_uboot_config sp7021_romter_p_defconfig
	set_kernel_config sp7021_chipP_emu_initramfs_defconfig
	set_bootfrom_config USB

	NEED_ISP=1
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
}

p_chip_config()
{
	case "$1" in
	"emmc")
		p_chip_emmc_config revB
		;;
	"sdcard")
		p_chip_emmc_config revB
		;;
	"spi_nand")
		p_chip_spi_nand_config revB
		;;
	"nor")
		p_chip_nor_config revB
		;;
	"tftp")
		p_chip_tftp_config revB
		;;
	"usb")
		p_chip_usb_config revB
		;;
	*)
		echo "Error: Unknown config!"
		exit 1
	esac
}

c_chip_spi_nand_config()
{
	if [ "$1" = "revA" ]; then
		XBOOT_CONFIG=q628_defconfig
	fi

	set_xboot_config q628_Rev2_SPINAND_defconfig
	set_uboot_config sp7021_nand_c_defconfig
	set_kernel_config sp7021_chipC_emu_nand_defconfig
	set_bootfrom_config NAND

	NEED_ISP=1
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
}

c_chip_para_nand_config()
{
	set_xboot_config
	set_uboot_config
	set_kernel_config
	set_bootfrom_config PNAND

	NEED_ISP=1
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
}

c_chip_spi_nor_config()
{
	if [ "$1" = "revA" ]; then
		XBOOT_CONFIG=q628_defconfig
	fi

	set_xboot_config q628_Rev2_EMMC_defconfig
	set_uboot_config sp7021_nor_c_defconfig
	set_kernel_config sp7021_chipC_emu_nor_defconfig
	set_bootfrom_config NOR_JFFS2
}

c_chip_emmc_config()
{
	if [ "$1" = "revA" ]; then
		XBOOT_CONFIG=q628_defconfig
	fi

	set_xboot_config q628_Rev2_EMMC_defconfig
	set_uboot_config sp7021_emmc_c_defconfig
	set_kernel_config sp7021_chipC_emu_defconfig
	set_bootfrom_config EMMC

	NEED_ISP=1
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
}

c_chip_nor_config()
{
	if [ "$1" = "revA" ]; then
		XBOOT_CONFIG=q628_defconfig
	fi

	set_xboot_config q628_Rev2_EMMC_defconfig
	set_uboot_config sp7021_romter_c_defconfig
	set_kernel_config sp7021_chipC_emu_initramfs_defconfig
	set_bootfrom_config SPINOR
}

c_chip_tftp_config()
{
	if [ "$1" = "revA" ]; then
		XBOOT_CONFIG=q628_defconfig
	fi

	set_xboot_config q628_Rev2_EMMC_defconfig
	set_uboot_config sp7021_romter_c_defconfig
	set_kernel_config sp7021_chipC_emu_initramfs_defconfig

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
	set_uboot_config sp7021_romter_c_defconfig
	set_kernel_config sp7021_chipC_emu_initramfs_defconfig
	set_bootfrom_config TFTP

	USER_NAME=$(whoami)
	echo "Your USER_NAME is ${USER_NAME}"
	echo "BOOT_KERNEL_FROM_TFTP="${BOOT_KERNEL_FROM_TFTP} >> ${BUILD_CONFIG}
	echo "USER_NAME=_"${USER_NAME} >> ${BUILD_CONFIG}
	echo "BOARD_MAC_ADDR="${BOARD_MAC_ADDR} >> ${BUILD_CONFIG}
	echo "TFTP_SERVER_IP="${TFTP_SERVER_IP} >> ${BUILD_CONFIG}
	echo "TFTP_SERVER_PATH="${TFTP_SERVER_PATH} >> ${BUILD_CONFIG}
}

c_chip_usb_config()
{
	if [ "$1" = "revA" ]; then
		XBOOT_CONFIG=q628_defconfig
	fi

	set_xboot_config q628_Rev2_EMMC_defconfig
	set_uboot_config sp7021_romter_c_defconfig
	set_kernel_config sp7021_chipC_emu_initramfs_defconfig
	set_bootfrom_config USB

	NEED_ISP=1
	echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
}

c_chip_config()
{
	case "$1" in
	"emmc")
		c_chip_emmc_config revB
		;;
	"sdcard")
		c_chip_emmc_config revB
		;;
	"spi_nand")
		c_chip_spi_nand_config revB
		;;
	"spi_nor")
		c_chip_spi_nor_config revB
		;;
	"nor")
		c_chip_nor_config revB
		;;
	"tftp")
		c_chip_tftp_config revB
		;;
	"usb")
		c_chip_usb_config revB
		;;
	"para_nand")
		c_chip_para_nand_config revB
		;;
	*)
		echo "Error: Unknown config!"
		exit 1
	esac
}

others_config()
{
	$ECHO $COLOR_GREEN"Initial all configs."$COLOR_ORIGIN

	$ECHO $COLOR_GREEN"Select xboot config :"$COLOR_ORIGIN
	$ECHO " ==============================================="
	find $XBOOT_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f -name "*_defconfig" | sort -i | sed "s,"$XBOOT_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t,] ,g" | sed "s,^ , [,g"
	$ECHO ""
	read XBOOT_CONFIG_NUM
	if [ -z $XBOOT_CONFIG_NUM ]; then
		$ECHO $COLOR_RED"Error: Unknown config num!"$COLOR_ORIGIN
		exit 1;
	fi
	XBOOT_CONFIG=$(find $XBOOT_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f  -name "*_defconfig" | sort -i | sed "s,"$XBOOT_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t, ,g" | sed -n $XBOOT_CONFIG_NUM"p" | sed -r "s, +[0-9]* ,,g")

	$ECHO $COLOR_GREEN"Select uboot config :"$COLOR_ORIGIN
	$ECHO " ==============================================="
	find $UBOOT_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f -name "*" | sort -i | sed "s,"$UBOOT_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t,] ,g" | sed "s,^ , [,g"
	$ECHO ""
	read UBOOT_CONFIG_NUM
	if [ -z $UBOOT_CONFIG_NUM ]; then
		$ECHO $COLOR_RED"Error: Unknown config num!"$COLOR_ORIGIN
		exit 1;
	fi
	UBOOT_CONFIG=$(find $UBOOT_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f -name "*" | sort -i | sed "s,"$UBOOT_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t, ,g" | sed -n $UBOOT_CONFIG_NUM"p" | sed -r "s, +[0-9]* ,,g")

	$ECHO $COLOR_GREEN"Select kernel config :"$COLOR_ORIGIN
	$ECHO " ==============================================="
	find $KERNEL_ARM_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f -name "*" | sort -i | sed "s,"$KERNEL_ARM_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t,] ,g" | sed "s,^ , [,g"
	$ECHO ""
	read KERNEL_CONFIG_NUM
	if [ -z $KERNEL_CONFIG_NUM ]; then
		$ECHO $COLOR_RED"Error: Unknown config num!"$COLOR_ORIGIN
		exit 1;
	fi
	KERNEL_CONFIG=$(find $KERNEL_ARM_CONFIG_ROOT -maxdepth 1 -mindepth 1 -type f -name "*" | sort -i | sed "s,"$KERNEL_ARM_CONFIG_ROOT"/,,g" | nl -b an -w 3 | sed "s,\t, ,g" | sed -n $KERNEL_CONFIG_NUM"p" | sed -r "s, +[0-9]* ,,g")

	$ECHO $COLOR_GREEN"Select rootfs config :"$COLOR_ORIGIN
	$ECHO " ==============================================="
	$ECHO " [1] v5"
	$ECHO " [2] v7"
	$ECHO " ==============================================="
	read ROOTFS_CONFIG_NUM
	if [ $ROOTFS_CONFIG_NUM = '1' ]; then
		ROOTFS_CONFIG=v5
	elif [ $ROOTFS_CONFIG_NUM = '2' ]; then
		ROOTFS_CONFIG=v7
	fi

	$ECHO $COLOR_GREEN"Select compiler config :"$COLOR_ORIGIN
	$ECHO " ==============================================="
	$ECHO " [1] v5"
	$ECHO " [2] v7"
	$ECHO " ==============================================="
	read COMPILER_CONFIG_NUM
	if [ $COMPILER_CONFIG_NUM = '1' ]; then
		CROSS_COMPILE=$1
	elif [ $COMPILER_CONFIG_NUM = '2' ]; then
		CROSS_COMPILE=$2
	fi

	$ECHO $COLOR_GREEN"Need isp?"$COLOR_ORIGIN
	$ECHO " ==============================================="
	$ECHO " y/n"
	$ECHO " ==============================================="
	read NEED_ISP_CONFIG
	if [ $NEED_ISP_CONFIG = 'y' ]; then
		NEED_ISP=1
	elif [ $NEED_ISP_CONFIG = 'n' ]; then
		NEED_ISP=0
	fi

	$ECHO $COLOR_GREEN"Zebu run?"$COLOR_ORIGIN
	$ECHO " ==============================================="
	$ECHO " y/n"
	$ECHO " ==============================================="
	read NEED_ZEBU_RUN
	if [ $NEED_ZEBU_RUN = 'y' ]; then
		ZEBU_RUN=1
	elif [ $NEED_ZEBU_RUN = 'n' ]; then
		ZEBU_RUN=0
	fi

	echo "XBOOT_CONFIG=${XBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $BUILD_CONFIG
	echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=${ROOTFS_CONFIG}" >> $BUILD_CONFIG
	echo "CROSS_COMPILE="$CROSS_COMPILE >> $BUILD_CONFIG
	if [ $NEED_ISP = '1' ]; then
		echo "NEED_ISP="$NEED_ISP >> $BUILD_CONFIG
	fi
	if [ $ZEBU_RUN = '1' ]; then
		echo "ZEBU_RUN="$ZEBU_RUN >> $BUILD_CONFIG
	fi
}

num=0
bootdev=
chip=1
runzebu=0
zmem=0
rootfs_content=BUSYBOX

list_config()
{
	sel=1
	if [ "$board" = "1" -o "$board" = "21" -o "$board" = "31" ]; then
		# chip == C
		if [ "$chip" = "1" ]; then # board == ev
			$ECHO $COLOR_YELLOW"[1] eMMC"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[2] SPI-NAND"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[3] SPI-NOR (jffs2)"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[4] NOR/Romter (initramfs)"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[5] SD Card"$COLOR_ORIGIN
			if [ "$board" = "1" -o "$board" = "31" ]; then
			$ECHO $COLOR_YELLOW"[6] TFTP server"$COLOR_ORIGIN
			fi
			if [ "$board" = "1" ]; then
			$ECHO $COLOR_YELLOW"[7] USB"$COLOR_ORIGIN
			fi
			if [ "$board" = "31" ]; then
			$ECHO $COLOR_YELLOW"[8] 8-bit NAND"$COLOR_ORIGIN
			fi
			read sel
			case "$sel" in
			"1")
				bootdev=emmc
				;;
			"2")
				bootdev=spi_nand
				;;
			"3")
				bootdev=spi_nor
				;;
			"4")
				bootdev=nor
				;;
			"5")
				bootdev=emmc
				if [ "$board" = "21" -o "$board" = "31" ]; then
					bootdev=sdcard
				fi
				BOOT_FROM=SDCARD
				;;
			"6")
				bootdev=tftp
				;;
			"7")
				bootdev=usb
				;;
			"8")
				bootdev=para_nand
				;;
			*)
				echo "Error: Unknown config!"
				exit 1
			esac
		elif [ "$chip" = "2" ]; then
			$ECHO $COLOR_YELLOW"[1] eMMC"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[2] SPI-NAND"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[3] NOR/Romter"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[4] SD Card"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[5] TFTP server"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[6] USB"$COLOR_ORIGIN
			read sel
			case "$sel" in
			"1")
				bootdev=emmc
				;;
			"2")
				bootdev=spi_nand
				;;
			"3")
				bootdev=nor
				;;
			"4")
				bootdev=emmc
				BOOT_FROM=SDCARD
				;;
			"5")
				bootdev=tftp
				;;
			"6")
				bootdev=usb
				;;
			*)
				echo "Error: Unknown config!"
				exit 1
			esac
		else
			echo "Error: Unknown chip!"
			exit 1
		fi
	elif [ "$board" = "22" -o "$board" = "32" ]; then
		zmem=1
		runzebu=1
		bootdev=nor
		echo "ZMEM=1" >> $BUILD_CONFIG
	else
		if [ "$board" != "2" ]; then # board == ev
			$ECHO $COLOR_YELLOW"[1] eMMC"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[2] SD Card"$COLOR_ORIGIN
			read sel
		fi
		case "$sel" in
		"1")
			bootdev=emmc
			;;
		"2")
			bootdev=emmc
			BOOT_FROM=SDCARD
			;;
		*)
			echo "Error: Unknown config!"
			exit 1
		esac
	fi

	if [ "$bootdev" = "nor" -o "$bootdev" = "spi_nor" ]; then
		$ECHO $COLOR_GREEN"Select SPI-NOR size:"$COLOR_ORIGIN
		$ECHO $COLOR_YELLOW"[1] 16 MiB"$COLOR_ORIGIN
		$ECHO $COLOR_YELLOW"[2] 32 MiB"$COLOR_ORIGIN
		$ECHO $COLOR_YELLOW"[3] 64 MiB"$COLOR_ORIGIN
		read sel
		case "$sel" in
		"1")
			echo "FLASH_SIZE=16" >> $BUILD_CONFIG
			;;
		"2")
			echo "FLASH_SIZE=32" >> $BUILD_CONFIG
			;;
		"3")
			echo "FLASH_SIZE=64" >> $BUILD_CONFIG
			;;
		*)
			echo "Error: Unknown config!"
			exit 1
		esac
	fi

	if [ "$bootdev" = "emmc" -a "$BOOT_FROM" != "SDCARD" ]; then
		$ECHO $COLOR_GREEN"Select eMMC size:"$COLOR_ORIGIN
		$ECHO $COLOR_YELLOW"[1] 1 GiB"$COLOR_ORIGIN
		$ECHO $COLOR_YELLOW"[2] 2 GiB"$COLOR_ORIGIN
		$ECHO $COLOR_YELLOW"[3] 4 GiB"$COLOR_ORIGIN
		$ECHO $COLOR_YELLOW"[4] 8 GiB"$COLOR_ORIGIN
		$ECHO $COLOR_YELLOW"[5] 16 GiB"$COLOR_ORIGIN
		$ECHO $COLOR_YELLOW"[6] 32 GiB"$COLOR_ORIGIN
		read sel
		case "$sel" in
		"1")
			echo "FLASH_SIZE=1024" >> $BUILD_CONFIG
			;;
		"2")
			echo "FLASH_SIZE=2048" >> $BUILD_CONFIG
			;;
		"3")
			echo "FLASH_SIZE=4096" >> $BUILD_CONFIG
			;;
		"4")
			echo "FLASH_SIZE=8192" >> $BUILD_CONFIG
			;;
		"5")
			echo "FLASH_SIZE=16384" >> $BUILD_CONFIG
			;;
		"6")
			echo "FLASH_SIZE=32768" >> $BUILD_CONFIG
			;;
		*)
			echo "Error: Unknown config!"
			exit 1
		esac
	fi

	echo "PNAND_FLASH=0" >> $BUILD_CONFIG
	if [ "$board" = "1" ]; then
		if [ "$bootdev" = "spi_nand" ]; then
			$ECHO $COLOR_GREEN"Select NAND size:"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[1] 128 MiB"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[2] 256 MiB"$COLOR_ORIGIN
			read sel
			case "$sel" in
			"1")
				echo "FLASH_SIZE=128" >> $BUILD_CONFIG
				;;
			"2")
				echo "FLASH_SIZE=256" >> $BUILD_CONFIG
				;;
			*)
				echo "Error: Unknown config!"
				exit 1
			esac

			$ECHO $COLOR_GREEN"Select NAND page size:"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[1] 2 KiB"$COLOR_ORIGIN
			NAND_PAGE_SIZE=2
			echo "NAND_PAGE_SIZE=2" >> $BUILD_CONFIG

			$ECHO $COLOR_GREEN"Select NAND page count per block:"$COLOR_ORIGIN
			BLOCK_SIZE=$(($NAND_PAGE_SIZE*64))
			$ECHO $COLOR_YELLOW"[1] 64 (block size = $BLOCK_SIZE KiB)"$COLOR_ORIGIN
			echo "NAND_PAGE_CNT=64" >> $BUILD_CONFIG
		fi
	elif [ "$board" = "21" -o "$board" = "31" ]; then
		if [ "$bootdev" = "spi_nand" ]; then
			$ECHO $COLOR_GREEN"Select NAND size:"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[1] 128 MiB"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[2] 256 MiB"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[3] 512 MiB"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[4] 1 GiB"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[5] 2 GiB"$COLOR_ORIGIN
			read sel
			case "$sel" in
			"1")
				echo "FLASH_SIZE=128" >> $BUILD_CONFIG
				;;
			"2")
				echo "FLASH_SIZE=256" >> $BUILD_CONFIG
				;;
			"3")
				echo "FLASH_SIZE=512" >> $BUILD_CONFIG
				;;
			"4")
				echo "FLASH_SIZE=1024" >> $BUILD_CONFIG
				;;
			"5")
				echo "FLASH_SIZE=2048" >> $BUILD_CONFIG
				;;
			*)
				echo "Error: Unknown config!"
				exit 1
			esac

			$ECHO $COLOR_GREEN"Select NAND page size:"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[1] 2 KiB"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[2] 4 KiB"$COLOR_ORIGIN
			read sel
			case "$sel" in
			"1")
				NAND_PAGE_SIZE=2
				echo "NAND_PAGE_SIZE=2" >> $BUILD_CONFIG
				;;
			"2")
				NAND_PAGE_SIZE=4
				echo "NAND_PAGE_SIZE=4" >> $BUILD_CONFIG
				;;
			*)
				echo "Error: Unknown config!"
				exit 1
			esac

			$ECHO $COLOR_GREEN"Select NAND page count per block:"$COLOR_ORIGIN
			BLOCK_SIZE=$(($NAND_PAGE_SIZE*64))
			$ECHO $COLOR_YELLOW"[1] 64 (block size = $BLOCK_SIZE KiB)"$COLOR_ORIGIN
			BLOCK_SIZE=$(($NAND_PAGE_SIZE*128))
			$ECHO $COLOR_YELLOW"[2] 128 (block size = $BLOCK_SIZE KiB)"$COLOR_ORIGIN
			read sel
			case "$sel" in
			"1")
				echo "NAND_PAGE_CNT=64" >> $BUILD_CONFIG
				;;
			"2")
				echo "NAND_PAGE_CNT=128" >> $BUILD_CONFIG
				;;
			*)
				echo "Error: Unknown config!"
				exit 1
			esac
		elif [ "$bootdev" = "para_nand" ]; then
			$ECHO $COLOR_GREEN"Select NAND size:"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[1] 128 MiB"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[2] 256 MiB"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[3] 512 MiB"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[4] 1 GiB"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[5] 2 GiB"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[6] 4 GiB"$COLOR_ORIGIN
			read sel
			case "$sel" in
			"1")
				echo "FLASH_SIZE=128" >> $BUILD_CONFIG
				;;
			"2")
				echo "FLASH_SIZE=256" >> $BUILD_CONFIG
				;;
			"3")
				echo "FLASH_SIZE=512" >> $BUILD_CONFIG
				;;
			"4")
				echo "FLASH_SIZE=1024" >> $BUILD_CONFIG
				;;
			"5")
				echo "FLASH_SIZE=2048" >> $BUILD_CONFIG
				;;
			"6")
				echo "FLASH_SIZE=4096" >> $BUILD_CONFIG
				;;
			*)
				echo "Error: Unknown config!"
				exit 1
			esac

			$ECHO $COLOR_GREEN"Select NAND page size:"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[1] 2 KiB"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[2] 4 KiB"$COLOR_ORIGIN
			$ECHO $COLOR_YELLOW"[3] 8 KiB"$COLOR_ORIGIN
			read sel
			case "$sel" in
			"1")
				NAND_PAGE_SIZE=2
				echo "NAND_PAGE_SIZE=2" >> $BUILD_CONFIG
				;;
			"2")
				NAND_PAGE_SIZE=4
				echo "NAND_PAGE_SIZE=4" >> $BUILD_CONFIG
				;;
			"3")
				NAND_PAGE_SIZE=8
				echo "NAND_PAGE_SIZE=8" >> $BUILD_CONFIG
				;;
			*)
				echo "Error: Unknown config!"
				exit 1
			esac

			$ECHO $COLOR_GREEN"Select NAND page count per block:"$COLOR_ORIGIN
			BLOCK_SIZE=$(($NAND_PAGE_SIZE*64))
			$ECHO $COLOR_YELLOW"[1] 64 (block size = $BLOCK_SIZE KiB)"$COLOR_ORIGIN
			BLOCK_SIZE=$(($NAND_PAGE_SIZE*128))
			$ECHO $COLOR_YELLOW"[2] 128 (block size = $BLOCK_SIZE KiB)"$COLOR_ORIGIN
			read sel
			case "$sel" in
			"1")
				echo "NAND_PAGE_CNT=64" >> $BUILD_CONFIG
				;;
			"2")
				echo "NAND_PAGE_CNT=128" >> $BUILD_CONFIG
				;;
			*)
				echo "Error: Unknown config!"
				exit 1
			esac
		fi
	fi

	if [ "$bootdev" = "emmc" -o "$bootdev" = "usb" -o "$bootdev" = "sdcard"  ]; then
		$ECHO $COLOR_GREEN"Select rootfs:"$COLOR_ORIGIN
		$ECHO $COLOR_YELLOW"[1] BusyBox"$COLOR_ORIGIN
		$ECHO $COLOR_YELLOW"[2] Yocto"$COLOR_ORIGIN
		read sel
		case "$sel" in
		"2")
			rootfs_content=YOCTO
			;;
		*)
			sel=1
		esac
	fi
}

$ECHO $COLOR_GREEN"Select boards:"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[1] SP7021 Ev Board"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[2] LTPP3G2 Board"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[3] SP7021 Demo Brd V2"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[4] SP7021 Demo Brd V3"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[5] BPI-F2S Board"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[6] BPI-F2P Board"$COLOR_ORIGIN
$ECHO $COLOR_YELLOW"[7] LTPP3G2 Board (S+)"$COLOR_ORIGIN
read board

echo "CHIP=Q628" > $BUILD_CONFIG
if [ "$board" = "1" ]; then
	echo "LINUX_DTB=sp7021-ev" >> $BUILD_CONFIG
	# $ECHO $COLOR_GREEN"Select chip:"$COLOR_ORIGIN
	# $ECHO $COLOR_YELLOW"[1] Chip C (ARM Cortex-A7 x4)"$COLOR_ORIGIN
	# $ECHO $COLOR_YELLOW"[2] Chip P (ARM A926)"$COLOR_ORIGIN
	# read chip
	chip=1
elif [ "$board" = "2" ]; then
	echo "LINUX_DTB=sp7021-ltpp3g2revD" >> $BUILD_CONFIG
	UBOOT_CONFIG=sp7021_tppg2_defconfig
	KERNEL_CONFIG=sp7021_chipC_ltpp3g2_defconfig
elif [ "$board" = "3" ]; then
	echo "LINUX_DTB=sp7021-demov2" >> $BUILD_CONFIG
	UBOOT_CONFIG=sp7021_demov2_defconfig
	KERNEL_CONFIG=sp7021_chipC_demov2_defconfig
elif [ "$board" = "4" ]; then
	echo "LINUX_DTB=sp7021-demov3" >> $BUILD_CONFIG
	UBOOT_CONFIG=sp7021_demov3_defconfig
	KERNEL_CONFIG=sp7021_chipC_demov3_defconfig
elif [ "$board" = "5" ]; then
	echo "LINUX_DTB=sp7021-bpi-f2s" >> $BUILD_CONFIG
	UBOOT_CONFIG=sp7021_bpi_f2s_defconfig
	KERNEL_CONFIG=sp7021_chipC_bpi-f2s_defconfig
elif [ "$board" = "6" ]; then
	echo "LINUX_DTB=sp7021-bpi-f2p" >> $BUILD_CONFIG
	UBOOT_CONFIG=sp7021_bpi_f2p_defconfig
	KERNEL_CONFIG=sp7021_chipC_bpi-f2p_defconfig
elif [ "$board" = "7" ]; then
	echo "LINUX_DTB=sp7021-ltpp3g2-sunplus" >> $BUILD_CONFIG
	UBOOT_CONFIG=sp7021_tppg2sunplus_defconfig
	KERNEL_CONFIG=sp7021_chipC_ltpp3g2sunplus_defconfig
#elif [ "$board" = "21" -o "$board" = "22" ]; then:
#	ARCH=arm64
#	echo "CHIP=Q645" > $BUILD_CONFIG
#	echo "LINUX_DTB=sunplus/q645-ev" >> $BUILD_CONFIG
#elif [ "$board" = "31" -o "$board" = "32" ]; then
#	ARCH=arm64
#	echo "CHIP=SP7350" > $BUILD_CONFIG
#	echo "LINUX_DTB=sunplus/sp7350-ev" >> $BUILD_CONFIG
else
	echo "Error: Unknown board!"
	exit 1
fi

if [ "$chip" = "1" ]; then
	$ECHO $COLOR_GREEN"Select boot devices:"$COLOR_ORIGIN
	num=2
	echo "CROSS_COMPILE="$1 >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=v7" >> $BUILD_CONFIG
	echo "BOOT_CHIP=C_CHIP" >> $BUILD_CONFIG

elif [ "$chip" = "2" ]; then
	$ECHO $COLOR_GREEN"Select boot devices (P chip):"$COLOR_ORIGIN
	num=1
	echo "CROSS_COMPILE="$1 >> $BUILD_CONFIG
	echo "ROOTFS_CONFIG=v5" >> $BUILD_CONFIG
	echo "BOOT_CHIP=P_CHIP" >> $BUILD_CONFIG
fi

list_config

################################################################################
##
## use product name, bootdev, chip, board to combine into a deconfig file name
## so, the defconfig file name must follow named rule like
##
## non-zebu:
##     xboot, uboot:
##         ${pid}_${bootdev}_${chip}_defconfig           --> q645_emmc_c_defconfig
##	   linux:
##         ${pid}_${bootdev}_${chip}_${board}_defconfig	 --> q645_emmc_c_ev_defconfig
##
## zebu:
##     xboot:
##         ${pid}_${chip}_zmem_defconfig      --> q645_c_zmem_defconfig
##     uboot:
##         ${pid}_${chip}_zebu_defconfig      --> q645_c_zebu_defconfig
##     linux:
##         ${pid}_${chip}_zebu_defconfig      --> q645_c_zebu_defconfig

set_config_directly=0

if [ "$board" = "21" -o "$board" = "22" ]; then
	## board = q645
	$ECHO $COLOR_GREEN"Select secure modes:"$COLOR_ORIGIN
	$ECHO $COLOR_YELLOW"[1] No secure (default)"$COLOR_ORIGIN
	$ECHO $COLOR_YELLOW"[2] Enable digital signature"$COLOR_ORIGIN
	$ECHO $COLOR_YELLOW"[3] Enable digital signature & Encryption"$COLOR_ORIGIN
	read secure

	if [ "$secure" = "2" ]; then
		echo "SECURE=1" >> $BUILD_CONFIG
	elif [ "$secure" = "3" ]; then
		echo "SECURE=1" >> $BUILD_CONFIG
		echo "ENCRYPTION=1" >> $BUILD_CONFIG
	fi

	sel_chip=$(chip_lookup $chip)
	sel_board=ev
	if [ "$board" = "22" ]; then
		sel_board=zebu
	fi
	set_config_directly=1
	chip_name="q645"
fi

if [ "$board" = "31" -o "$board" = "32" ]; then
	## board = SP7350
	$ECHO $COLOR_GREEN"Select secure modes:"$COLOR_ORIGIN
	$ECHO $COLOR_YELLOW"[1] No secure (default)"$COLOR_ORIGIN
	$ECHO $COLOR_YELLOW"[2] Enable digital signature"$COLOR_ORIGIN
	$ECHO $COLOR_YELLOW"[3] Enable digital signature & Encryption"$COLOR_ORIGIN
	read secure

	if [ "$secure" = "2" ]; then
		echo "SECURE=1" >> $BUILD_CONFIG
	elif [ "$secure" = "3" ]; then
		echo "SECURE=1" >> $BUILD_CONFIG
		echo "ENCRYPTION=1" >> $BUILD_CONFIG
	fi

	sel_chip=$(chip_lookup $chip)
	sel_board=ev
	if [ "$board" = "32" ]; then
		sel_board=zebu
	fi
	set_config_directly=1
	chip_name="sp7350"
fi

if [ "$set_config_directly" = "1" ]; then
	xboot_bootdev=$bootdev
	if [ "$bootdev" = "sdcard" -o "$bootdev" = "usb" ]; then
		xboot_bootdev="emmc"
	fi
	XBOOT_CONFIG=$(xboot_defconfig_combine $chip_name $xboot_bootdev $sel_chip $sel_board $zmem)
	UBOOT_CONFIG=$(uboot_defconfig_combine $chip_name $bootdev $sel_chip $sel_board $zmem)
	KERNEL_CONFIG=$(linux_defconfig_combine $chip_name $bootdev $sel_chip $sel_board)
fi

echo "ROOTFS_CONTENT=${rootfs_content}" >> $BUILD_CONFIG

################################################################################

if [ "$runzebu" = "1" ]; then
	echo "ZEBU_RUN=1" >> $BUILD_CONFIG
fi

echo "ARCH=$ARCH" >> $BUILD_CONFIG

echo "bootdev "$bootdev

case "$num" in
	1)
		p_chip_config $bootdev
		;;
	2)
		c_chip_config $bootdev
		;;
	# 6)
	# 	others_config $1 $2
	# 	;;
	*)
		echo "Error: Unknown config!"
		exit 1
esac
