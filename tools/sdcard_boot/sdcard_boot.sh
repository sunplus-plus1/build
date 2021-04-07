#!/bin/bash

TOP=../../..

# Generate a disk image containing FAT32 and EXT4 partitions.
# ISPBOOOT.BIN, u-boot.img, uImage, a926.img, and uEnv.txt
# are placed on the FAT32 partition, and uncompressed root
# file-system is placed on the EXT4 partition.
# 1. Create boot (FAT32) partition.
# 2. Copy ISPBOOOT.BIN, u-boot.img, uImage, a926.img, and
#    uEnv.txt to it.
# 3. Copy boot partition to output file 'ISP_SD_BOOOT.img'.
# 4. Create root (ext4) partition.
# 5. Copy 'rc.sdcardboot' to '/etc/init.d' of root partition.
# 6. Resize root partition.
# 7. Copy root partition to output file 'ISP_SD_BOOOT.img'.
# 8. Create partition table.

MKFS=$TOP/linux/rootfs/tools/mke2fs
RESIZE=$TOP/linux/rootfs/tools/resize2fs
OUTPATH=$TOP/out/boot2linux_SDcard
FAT_FILE_IN=$OUTPATH
ROOT_DIR_IN=$TOP/linux/rootfs/initramfs/disk
ROOT_IMG=$OUTPATH/../rootfs.img
OUT_FILE=$OUTPATH/ISP_SD_BOOOT.img
FAT_IMG_OUT=fat.img
EXT_ENV=uEnv.txt
EXT_ENV_RISCV=uEnv_riscv.txt
EXT_ENV_A64=uEnv_a64.txt
NONOS_IMG=a926.img
RC_SDCARDBOOTDIR=$ROOT_DIR_IN/etc/init.d
RC_SDCARDBOOTFILE=rc.sdcardboot

# Size of FAT32 partition size (unit: M)
FAT_IMG_SIZE_M=128

# Block size is 512 bytes for sfdisk and FAT32 sector is 1024 bytes
BLOCK_SIZE=512
FAT_SECTOR=1024

# fat.img offset 1M for EFI
seek_offset=1024
seek_bs=1024

# Check file
if [ -f $OUT_FILE ]; then
	rm -rf $OUT_FILE
fi

if [ ! -d $FAT_FILE_IN ]; then
	echo "Error: $FAT_FILE_IN doesn't exist!"
	exit 1
fi

if [ ! -d $ROOT_DIR_IN ]; then
	echo "Error: $WORK_DIR doesn't exist!"
	exit 1
fi

# cp uEnv.txt to out/sdcardboot
if [ $1 -eq "1" ]; then
	cp $EXT_ENV_RISCV $OUTPATH/$EXT_ENV
elif [ $1 -eq "2" ]; then
	cp $EXT_ENV_A64 $OUTPATH/$EXT_ENV
else
	cp $EXT_ENV $OUTPATH
fi

# Calculate parameter.
partition_size_1=$(($FAT_IMG_SIZE_M*1024*1024))

# Check size of FAT32 partition.
rm -f "$FAT_IMG_OUT"

sz=`du -sb $FAT_FILE_IN | cut -f1`
if [ $sz -gt $partition_size_1 ]; then
	echo "Size of '$FAT_FILE_IN' (${sz} bytes) is too larger."
	echo "Please modify FAT_IMG_SIZE_M (${partition_size_1} bytes)."
	exit 1;
fi

if [ -x "$(command -v mkfs.fat)" ]; then
	echo '###### do mkfs.fat cmd ########'
	mkfs.fat -F 32 -C "$FAT_IMG_OUT" "$(($partition_size_1/$FAT_SECTOR))"
	if [ $? -ne 0 ]; then
		exit
	fi
else
	if [ -x "$(command -v mkfs.vfat)" ]; then
		echo '###### do mkfs.vfat cmd ########'
		mkfs.vfat -F 32 -C "$FAT_IMG_OUT" "$(($partition_size_1/$FAT_SECTOR))"
		if [ $? -ne 0 ]; then
			exit
		fi
	else
		echo "No mkfs.fat and mkfs.vfat cmd, please install it!"
		exit
	fi
fi

if [ -x "$(command -v mcopy)" ]; then
	echo '###### do the mcopy cmd ########'
	mcopy -i "$FAT_IMG_OUT" -s "$FAT_FILE_IN/ISPBOOOT.BIN" "$OUTPATH/$EXT_ENV" "$FAT_FILE_IN/uImage" "$FAT_FILE_IN/u-boot.img" ::
	if [ -f $FAT_FILE_IN/$NONOS_IMG ]; then
		mcopy -i "$FAT_IMG_OUT" -s "$FAT_FILE_IN/$NONOS_IMG" ::
	fi
	if [ $? -ne 0 ]; then
		exit
	fi
else
	echo "No mcopy cmd, please install it!"
	exit
fi

# Offset boot partition (FAT32)
dd if="$FAT_IMG_OUT" of="$OUT_FILE" bs="$seek_bs" seek="$seek_offset"
rm -f "$FAT_IMG_OUT"

# Create root partition (ext4)
# Copy 'rc.sdcardboot' to '/etc/init.d' of root partition.
cp -rf "$RC_SDCARDBOOTFILE" $RC_SDCARDBOOTDIR

# Calculate size of root partition (assume 40% + 20MB overhead).
sz=`du -sb $ROOT_DIR_IN | cut -f1`
sz=$((sz*14/10))
partition_size_2=$((sz/1024/1024+20))

echo '###### do mke2fs cmd (mke2fs version needs to bigger than 1.45.1) ########'
chmod 777 $ROOT_DIR_IN/bin/busybox
rm -f "$ROOT_IMG"
$MKFS -t ext4 -b 4096 -d "$ROOT_DIR_IN" "$ROOT_IMG" "$((partition_size_2))M"
if [ $? -ne 0 ]; then
	exit
fi

# Resize to minimum + 10%. resize2fs version needs to bigger than 1.45.1.
partition_sz_2=`$RESIZE -P $ROOT_IMG | cut -d: -f2`
partition_sz_2=$((partition_sz_2*11/10+1))
$RESIZE $ROOT_IMG $partition_sz_2

# Offset root partition (ext4)
dd if="$ROOT_IMG" of="$OUT_FILE" bs="$seek_bs" seek="$(($seek_offset+$partition_size_1/$seek_bs))"

# Create the partition info
partition_size_2=`du -sb $ROOT_IMG | cut -f1`
partition_size_2=$(((partition_size_2+65535)/65536))
partition_size_2=$((partition_size_2*65536))
echo '###### do sfdisk cmd (sfdisk version need to bigger than 2.27.1) ########'
if [ -x "$(command -v sfdisk)" ]; then
	sfdisk -v
	printf "type=b, size=$(($partition_size_1/$BLOCK_SIZE))
		type=83, size=$(($partition_size_2/$BLOCK_SIZE))" |
	sfdisk "$OUT_FILE"
else
	echo "no sfdisk cmd, please install it"
	exit
fi
