#!/bin/bash

source sb_info.sh_inc

HOUT=hsm_keys

# if exists, ask if delete
if [ -d  $HOUT ];then
#	echo "Caution: HSM keys $HOUT/ already exists. Do you want to remove it and recreate $HOUT/ ?(y/n)"
#	read ans
#	if [ "$ans" = "y" ] || [ "$ans" = "Y" ] ;then
#		rm -rf ${HOUT}
#	else
	echo "Caution: HSM keys $HOUT/ already exists!"
	exit 0
#	fi
fi

mkdir ${HOUT}

OUTPUT=$HOUT/hsmk.bin

# $1: val
# $2: 1=no reverse
# $3: 1=have secure boot signature
# $4: xboot version

OUT_TMP=$HOUT/tmp
function gen_bin_tmp
{
        #echo $1
        if [ "$2" = "1" ];then
                printf "0: %.8x" $1 | xxd -r -g0 >$OUT_TMP
        else
                printf "0: %.8x" $1 | sed -E 's/0: (..)(..)(..)(..)/0: \4\3\2\1/' | xxd -r -g0 >$OUT_TMP
        fi
        #hexdump -C $OUT_TMP
}

# 4-byte magic @ offset 0
val=$((HSMK_MAGIC))
gen_bin_tmp $val
dd if=$OUT_TMP of=$OUTPUT conv=notrunc bs=1 count=4 seek=$HSMK_MAGIC_OFF 2>/dev/null
rm -f $OUT_TMP

echo "* gen HSM DUK (16 bytes)"
K_FILE=$HOUT/key_duk.bin
dd if=/dev/urandom of=$K_FILE bs=1 count=16 2>/dev/null
dd if=$K_FILE of=$OUTPUT conv=notrunc bs=1 count=16 seek=$HSMK_DUK_OFF 2>/dev/null
ls -l $K_FILE

echo "* gen HSM BBR key (16 bytes)"
K_FILE=$HOUT/key_bbr.bin
dd if=/dev/urandom of=$K_FILE bs=1 count=16 2>/dev/null
dd if=$K_FILE of=$OUTPUT conv=notrunc bs=1 count=16 seek=$HSMK_BBR_OFF 2>/dev/null
ls -l $K_FILE

echo "* gen HSM APP0 key (16 bytes)"
K_FILE=$HOUT/key_app0.bin
dd if=/dev/urandom of=$K_FILE bs=1 count=16 2>/dev/null
dd if=$K_FILE of=$OUTPUT conv=notrunc bs=1 count=16 seek=$HSMK_APP0_OFF 2>/dev/null
ls -l $K_FILE

echo "* gen HSM APP1 key (16 bytes)"
K_FILE=$HOUT/key_app1.bin
dd if=/dev/urandom of=$K_FILE bs=1 count=16 2>/dev/null
dd if=$K_FILE of=$OUTPUT conv=notrunc bs=1 count=16 seek=$HSMK_APP1_OFF 2>/dev/null
ls -l $K_FILE

echo "* gen HSM ADC key (16 bytes)"
K_FILE=$HOUT/key_adc.bin
dd if=/dev/urandom of=$K_FILE bs=1 count=16 2>/dev/null
dd if=$K_FILE of=$OUTPUT conv=notrunc bs=1 count=16 seek=$HSMK_ADC_OFF 2>/dev/null
ls -l $K_FILE

# user key legnth can vary. 4 is only for test.
LEN_USER_KEYS=4
echo "* gen HSM user key ($LEN_USER_KEYS bytes)"

# len_user_keys
val=$LEN_USER_KEYS
gen_bin_tmp $val
dd if=$OUT_TMP of=$OUTPUT conv=notrunc bs=1 count=4 seek=$HSMK_LEN_USRK_OFF 2>/dev/null
rm -f $OUT_TMP

# user_keys
K_FILE=$HOUT/user_keys.bin
dd if=/dev/urandom of=$K_FILE bs=1 count=$LEN_USER_KEYS 2>/dev/null

dd if=$K_FILE of=$OUTPUT conv=notrunc bs=1 count=$LEN_USER_KEYS seek=$HSMK_USRK_OFF 2>/dev/null
ls -l $OUTPUT


echo "copy hsm_keys  to boot/xboot/secure !!!"
cp hsm_keys ../../../../boot/xboot/secure -rf
echo ""
