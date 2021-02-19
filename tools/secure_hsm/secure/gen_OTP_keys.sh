#!/bin/bash

source sb_info.sh_inc

if [ ! -x $ED_MKEY_TOOL ];then
	echo "Error: can't execute $ED_MKEY_TOOL"
	exit 1
fi
if [ ! -x $X25519_MKEY_TOOL ];then
	echo "Error: can't execute $X25519_MKEY_TOOL"
	exit 1
fi
if [ ! -x $SHA3_TOOL ];then
	echo "Error: can't execute $SHA3_TOOL"
	exit 1
fi

# // ECIES encryption of KAES :
# u32 eph_IV[3];         // ephemeral IV
# u32 eph_Kpub;          // ECIES: ephemeral publick key

# move existing dirs to _old
if [ -d otp_Sb_keys ];then
	rm -rf OLD_otp_Sb_keys
	mv -v otp_Sb_keys OLD_otp_Sb_keys
fi
if [ -d otp_Device_keys ];then
	rm -rf OLD_otp_Device_keys
	mv -v otp_Device_keys OLD_otp_Device_keys
fi

echo "* gen ASYM key for Secure boot (ED25519 verification of image)"
$ED_MKEY_TOOL
mv keys otp_Sb_keys
$SHA3_TOOL 512 $SB_KPUB_HASH $SB_KPUB
echo ""
echo ""


echo "* gen ASYM key for encrption (ECIES use)"
$X25519_MKEY_TOOL
mv keys otp_Device_keys
$SHA3_TOOL 512 $DEV_KPRIV_HASH $DEV_KPRIV


echo ""
echo ""
