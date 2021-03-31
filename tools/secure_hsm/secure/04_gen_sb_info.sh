#/bin/bash

echo "$0"

source sb_info.sh_inc

function usage
{
	echo "usage : ./$0 [sb_flags=3]"
	echo "sb_flags : 1(sign), 2(encrypt), 3(sign and encrypt)"
}

if [ $# -gt 1 ];then
	usage
	exit 1
fi

# bit0=sign, bit1=encrypt
sb_flags=3
if [ "$1" != "" ];then
	sb_flags=$1
fi


# See ../include/bootmain.h, struct sb_info
OUTPUT=out/sb_info.bin

# must run gen_Build_keys.sh to have thes bin files:
IV_FILE=build_keys/eph_IV.bin
EPH_KPUB=build_keys/ecies/x_pub_0.bin

# must run ECIES to gen encrypted KAES
KAES_AUTH=out/KAES_auth_tag.bin
KAES_EN=out/KAES_encrypted.bin
BODY_AUTH=out/body_auth_tag.bin
BODY_EN=out/body_encrypted.bin


# $1: val
# $2: 1=no reverse
# $3: 1=have secure boot signature
# $4: xboot version

OUT_TMP=out/tmp
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

dd if=/dev/zero of=$OUTPUT bs=1 count=$SB_INFO_SIZE 2>/dev/null

# 4-byte magic @ offset 0
val=$((SB_MAGIC))
gen_bin_tmp $val
dd if=$OUT_TMP of=$OUTPUT conv=notrunc bs=1 count=4 seek=$SB_MAGIC_OFF 2>/dev/null

# 4-byte sb_flags @ offset 4
val=$((sb_flags))
gen_bin_tmp $val
dd if=$OUT_TMP of=$OUTPUT conv=notrunc bs=1 count=4 seek=$SB_FLAGS_OFF 2>/dev/null

# 4-byte hash_Sb_Kpub @ offset 8
if [ ! -f $SB_KPUB_HASH ];then
	echo "Error: missed key hash $SB_KPUB_HASH"
	exit 1
fi
dd if=$SB_KPUB_HASH of=$OUTPUT conv=notrunc bs=1 count=4 seek=$SB_H_SBKEY_OFF 2>/dev/null

# 4-byte hash_Dev_Kpriv @ offset 12
if [ ! -f $DEV_KPRIV_HASH ];then
	echo "Error: missed key hash $DEV_KPRIV_HASH"
	exit 1
fi
dd if=$DEV_KPRIV_HASH of=$OUTPUT conv=notrunc bs=1 count=4 seek=$SB_H_DEKEY_OFF 2>/dev/null

# 64-byte signature @ offset 16
# it's zero before signing

# 32-byte eph_Kpub @ offset 80
if [ ! -f $EPH_KPUB ];then
	echo "Error: missed $EPH_KPUB"
	exit 1
fi
dd if=$EPH_KPUB of=$OUTPUT conv=notrunc bs=1 count=32  seek=$SB_E_KPUB_OFF 2>/dev/null

# 12-byte IV @ offset 112
if [ ! -f $IV_FILE ];then
	echo "Error: missed $IV_FILE"
	exit 1
fi
dd if=$IV_FILE of=$OUTPUT conv=notrunc bs=1 count=12 seek=$SB_IV_OFF 2>/dev/null

# 4-byte reserved_84@ offset 124

# 16-byte KAES_auth_tag @ offset 128
if [ ! -f $KAES_AUTH ];then
	echo "Error: missed $KAES_AUTH"
	exit 1
fi
dd if=$KAES_AUTH of=$OUTPUT conv=notrunc bs=1 count=16 seek=$SB_KA_AUTH_OFF 2>/dev/null

# 32-byte KAES_encrypted @ offset 144
if [ ! -f $KAES_EN ];then
	echo "Error: missed $KAES_EN"
	exit 1
fi
dd if=$KAES_EN of=$OUTPUT conv=notrunc bs=1 count=32 seek=$SB_KA_EN_OFF 2>/dev/null

# is xboot encrypted ?
if [ $((sb_flags & 2)) -ne 0 ];then
	# 16-byte body_auth_tag @ offset 176
	if [ ! -f $BODY_AUTH ];then
		echo "Error: missed $BODY_AUTH"
		exit 1
	fi
	dd if=$BODY_AUTH of=$OUTPUT conv=notrunc bs=1 count=16 seek=$SB_BD_AUTH_OFF 2>/dev/null

	# 4-byte body_cipher_len @ offset 192

	if [ ! -f $BODY_EN ];then
		echo "Error: missed $BODY_EN"
		exit 1
	fi
	val=`stat -c%s $BODY_EN`
	gen_bin_tmp $val
	dd if=$OUT_TMP of=$OUTPUT conv=notrunc bs=1 count=4 seek=$SB_BD_LEN_OFF 2>/dev/null
	echo -e  " \033[0;1;33;40m >>>>>signature + encrypt<<<< \033[0m "
else
	echo -e  " \033[0;1;33;40m >>>>>only signature<<<< \033[0m "
fi

# 4-byte reserved_188 @ offset 196

# total 200 bytes
#hexdump -C $OUTPUT

rm -f $OUT_TMP
