#/bin/bash
TOP=../../..

#Generate a virtual image containing FAT and EXT3 partitions,
#ISPBOOOT.bin placed on the FAT partition,and uncompressed rootfs placed on the EXT2 partition
#1.set the fat partition and copy ISPBOOOT.BIN to fat.img
#2.copy resize2fs to disk/sbin/
#3.set the ext3 partition 


OUTPATH=$TOP/out/boot2linux_SDcard
FAT_FILE_IN=$OUTPATH/ISPBOOOT.BIN
ROOT_DIR_IN=$TOP/linux/rootfs/initramfs/disk
OUT_FILE=$OUTPATH/ISP_SD_BOOOT.img
FAT_IMG_OUT=fat.img

#modify the rc.sdcardroot(EXT3 partition's first sector)
RC_SDCARDBOOTDIR=$ROOT_DIR_IN/etc/init.d
REPLAY_STR=PART_EXT_STARTSECTOR=
RC_SDCARDBOOTFILE=rc.sdcardboot
# part1 and part2 size unit:M
FAT_IMG_SIZE_M=10
ROOT_IMG_SIZE_M=20

# block size is 512byte for sfdisk set and FAT sector is 1024 default
BLOCK_SIZE=512
FAT_SECTOR=1024

# fat.img offset 1M for EFI
seek_offset=1024
seek_bs=1024


if [ -f $OUT_FILE ];then
	rm -rf $OUT_FILE
fi

if [ ! -f $FAT_FILE_IN ];then
	echo "Error: $FAT_FILE_IN doesn't exist!"
	exit 1
fi

if [ ! -d $ROOT_DIR_IN ];then
	echo "Error: $WORK_DIR doesn't exist!"
	exit 1
fi

# Calculated params.
mega="$(echo '2^20' | bc)"

partition_size_1=$(($FAT_IMG_SIZE_M * $mega))
partition_size_2=$(($ROOT_IMG_SIZE_M * $mega))

#create fat img
rm -f "$FAT_IMG_OUT"

sz=`du -sb $FAT_FILE_IN | cut -f1` ; \
echo "$FAT_FILE_IN size = %d (hex %x)\n" $$sz $$sz ; \
 if [ $$sz -gt $(FAT_FILE_IN) ];then \
	echo "$FAT_FILE_IN size($$sz) is too larger. Please increase the FAT_IMG_SIZE_M size($FAT_IMG_SIZE_M M).\n" ; \
	exit 1; \
 fi



mkfs.fat -F 32 -C "$FAT_IMG_OUT" "$(($partition_size_1/$FAT_SECTOR))"
mcopy -i "$FAT_IMG_OUT" -s "$FAT_FILE_IN" ::

# offset fat.img

dd if="$FAT_IMG_OUT" of="$OUT_FILE" bs="$seek_bs" seek="$seek_offset"
rm -f "$FAT_IMG_OUT"
#create and offset ext2.img 
#modify the ext partition's first sector 
firstSector=$((($partition_size_1+$seek_bs*$seek_offset)/$BLOCK_SIZE))
echo "EXT partition first sector = $firstSector"
sed -ri "/$REPLAY_STR/s/($REPLAY_STR)[0-9a-zA-Z ]+/\1$firstSector/" $RC_SDCARDBOOTFILE
cp -rf "$RC_SDCARDBOOTFILE" $RC_SDCARDBOOTDIR

./mke2fs -j -d "$ROOT_DIR_IN" \
  -r 1 \
  -N 0 \
  -m 5 \
  -L '' \
  -O ^64bit \
  -b 4096 \
  -E offset="$(($partition_size_1+$seek_bs*$seek_offset))" \
  "$OUT_FILE" "${ROOT_IMG_SIZE_M}M" \
;

printf "
type=b, size=$(($partition_size_1/$BLOCK_SIZE))
type=83, size=$(($partition_size_2/$BLOCK_SIZE))
" | sfdisk "$OUT_FILE"

rm -rf $FAT_FILE_IN
#to avoid switch to emmc and init from rc.sdcard
rm -rf $RC_SDCARDBOOTDIR/$RC_SDCARDBOOTFILE

