#!/bin/bash
TOP=../

export PATH=$PATH:$TOP/build/tools/isp/

X=xboot.img
U=u-boot.img
K=uImage
ROOTFS=rootfs.img
D=dtb
F=fip.img


# Partition name = file name
cp $X xboot0
cp $U uboot0
cp $X xboot1
cp $U uboot1
cp $U uboot2
cp $K kernel

if [ "$2" = "Q645" -o "$2" = "SP7350" ]; then
	cp $F fip
else
	touch reserve
fi

if [ "$1" != "SDCARD" ]; then
	cp $ROOTFS rootfs
fi

cp $D DTB

if [ "$1" = "PNAND" ]; then
	if [ -n "$3" ]; then
		NAND_SIZE=$(($3*0x100000))
	else
		NAND_SIZE=0x10000000	# default size = 256 MiB
	fi
	NAND_SIZE=$(($NAND_SIZE-0x2040000))
fi

partition=(xboot1 uboot1 uboot2 fip env env_redund dtb kernel rootfs)
size=(0x100000 0x100000 0x100000 0x200000 0x80000 0x80000 0x40000 0x1900000 $NAND_SIZE)

if [ -n "$4" ] && [ -n "$5" ]; then
	BLOCK_SIZE=$(($4*$5*1024))
	for i in ${!size[@]}; do
		if [ "${BLOCK_SIZE}" -gt "$((size[$i]))" ]; then
			size[$i]=${BLOCK_SIZE}
			echo ">>>" ${partition[$i]} "up to" ${BLOCK_SIZE}
		fi
		printf "%x\n" $((size[$i]))
	done
fi

# Note:
#     If partitions' sizes listed before "kernel" are changed,
#     please make sure U-Boot settings of CONFIG_ENV_OFFSET, CONFIG_ENV_SIZE, CONFIG_SRCADDR_KERNEL and CONFIG_SRCADDR_DTB
#     are changed accordingly.
for ADDR in "CONFIG_ENV_OFFSET" "CONFIG_ENV_SIZE" "CONFIG_SRCADDR_DTB" "CONFIG_SRCADDR_KERNEL"
do
	cat ${TOP}boot/uboot/.config | grep --color -e ${ADDR}
done

if [ "$1" = "EMMC" ]; then
	if [ -n "$3" ]; then
		EMMC_SIZE=$(($3*0x100000))
	else
		EMMC_SIZE=0x100000000	# default size = 4GiB
	fi
	EMMC_SIZE=$(($EMMC_SIZE-0x2000000))
	if [ "$2" = "Q645" -o "$2" = "SP7350" ]; then
		isp pack_image ISPBOOOT.BIN \
			xboot0 uboot0 \
			xboot1 0x100000 \
			uboot1 0x100000 \
			uboot2 0x100000 \
			fip 0x100000 \
			env 0x80000 \
			env_redund 0x80000 \
			dtb 0x40000 \
			kernel 0x2000000 \
			rootfs $EMMC_SIZE
	else
		isp pack_image ISPBOOOT.BIN \
			xboot0 uboot0 \
			xboot1 0x100000 \
			uboot1 0x100000 \
			uboot2 0x100000 \
			env 0x80000 \
			env_redund 0x80000 \
			reserve 0x100000 \
			dtb 0x40000 \
			kernel 0x2000000 \
			rootfs $EMMC_SIZE
	fi
elif [ "$1" = "NAND" ]; then
	if [ -n "$3" ]; then
		NAND_SIZE=$(($3*0x100000))
	else
		NAND_SIZE=0x10000000	# default size = 256 MiB
	fi

	if [ "$2" = "Q645" -o "$2" = "SP7350" ]; then
		NAND_SIZE=$(($NAND_SIZE-0x2100000))
		isp pack_image ISPBOOOT.BIN \
			xboot0 uboot0 \
			xboot1 0x100000 \
			uboot1 0x100000 \
			uboot2 0x100000 \
			fip 0x200000 \
			env 0x80000 \
			env_redund 0x80000 \
			dtb 0x40000 \
			kernel 0x1900000 \
			rootfs $NAND_SIZE
	else
		NAND_SIZE=$(($NAND_SIZE-0x2000000))
		isp pack_image ISPBOOOT.BIN \
			xboot0 uboot0 \
			xboot1 0x100000 \
			uboot1 0x100000 \
			uboot2 0x100000 \
			env 0x80000 \
			env_redund 0x80000 \
			reserve 0x100000 \
			dtb 0x40000 \
			kernel 0x1900000 \
			rootfs $NAND_SIZE
	fi

elif [ "$1" = "PNAND" ]; then
	isp pack_image ISPBOOOT.BIN \
		xboot0 uboot0 \
		${partition[0]} ${size[0]} \
		${partition[1]} ${size[1]} \
		${partition[2]} ${size[2]} \
		${partition[3]} ${size[3]} \
		${partition[4]} ${size[4]} \
		${partition[5]} ${size[5]} \
		${partition[6]} ${size[6]} \
		${partition[7]} ${size[7]} \
		${partition[8]} ${size[8]}

elif [ "$1" = "USB" ]; then
	if [ "$2" = "Q645" -o "$2" = "SP7350" ]; then
		isp pack_image ISPBOOOT.BIN \
			xboot0 uboot0 \
			xboot1 0x100000 \
			uboot1 0x100000 \
			fip 0x100000 \
			dtb 0x40000 \
			kernel 0xd80000
	else
		isp pack_image ISPBOOOT.BIN \
			xboot0 uboot0 \
			xboot1 0x100000 \
			uboot1 0x100000 \
			reserve 0x100000 \
			dtb 0x40000 \
			kernel 0xd80000
	fi
fi

rm -rf xboot0
rm -rf uboot0
rm -rf xboot1
rm -rf uboot1
rm -rf uboot2
rm -rf kernel
rm -rf DTB
rm -rf env
rm -rf env_redund
rm -rf rootfs
rm -rf reserve
rm -rf fip

# Create image for booting from SD card or USB storage.
if [ "$1" = "SDCARD" ]; then
	mkdir -p boot2linux_SDcard
	if [ "$2" = "Q645" -o "$2" = "SP7350" ]; then
		cp -rf $U $K $N $F ./boot2linux_SDcard
		dd if=$X of=boot2linux_SDcard/ISPBOOOT.BIN
	else
		cp -rf $U $K $N ./boot2linux_SDcard
		dd if=/dev/zero of=boot2linux_SDcard/ISPBOOOT.BIN bs=1024 count=64
		dd if=$X of=boot2linux_SDcard/ISPBOOOT.BIN conv=notrunc
	fi
fi
if [ "$1" = "USB" ]; then
	mkdir -p boot2linux_usb
	isp extract4boot2linux_usbboot ISPBOOOT.BIN boot2linux_usb/ISPBOOOT.BIN
	rm -f ISPBOOOT.BIN
fi

# Create image for partial update:
#     isp extract4update ISPBOOOT.BIN ISP_UPDT.BIN [list of partitions ...]
#   Example:
#     isp extract4update ISPBOOOT.BIN ISP_UPDT.BIN uboot2
#     isp extract4update ISPBOOOT.BIN ISP_UPDT.BIN kernel dtb
#     isp extract4update ISPBOOOT.BIN ISP_UPDT.BIN uboot2 kernel dtb
#
#   Execute update in U-Boot:
#     run update_usb
#     run update_sdcard
#

