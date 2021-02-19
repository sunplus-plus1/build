#!/bin/bash

echo "$0"

source sb_info.sh_inc

OUT_SS=build_keys/ss.bin
OUT_SESS_KEY=build_keys/sess_key.bin

echo "ECIES : X25519, KDF=HKDF-SHA512, E=AES-256-GCM"
echo ""

if [ ! -f $AESGCM_TOOL ];then
	echo "Missed tool: $AESGCM_TOOL"
	exit 1
fi
if [ ! -f $KDF_TOOL ];then
	echo "Missed tool: $KDF_TOOL"
	exit 1
fi
if [ ! -f $XSS_TOOL ];then
	echo "Missed tool: $XSS_TOOL"
	exit 1
fi

rm -f $OUT_SS
rm -f $OUT_SESS_KEY


# 1. gen shared secret = ECDH

echo "Private key: $DEV_KPRIV"
echo "Public key : $DEV_KPUB"

if [ ! -f $DEV_KPRIV ];then
	echo "Not found OTP key file: $DEV_KPRIV"
	exit 1
fi

echo "(1) ECDH : X25519"
echo ""
$XSS_TOOL -p "$DEV_KPRIV" -b "$DEV_KPUB" -o $OUT_SS
if [ $? -ne 0 ];then
	echo "key exchange program ($XSS_TOOL)  failed"
	exit 1
fi

echo "Output shared secret : $OUT_SS"



# 2. sess_key = HKDF_SHA512(ss.bin)
echo "(2) KDF : HKDF-SHA512"
echo ""
$KDF_TOOL 32 $OUT_SESS_KEY $OUT_SS 
if [ $? -ne 0 ];then
	echo "KDF program ($KDF_TOOL)  failed"
	exit 1
fi
echo "Output session key : $OUT_SESS_KEY"

# remove ss since key is derived
#rm -f $OUT_SS


# 3. encrypt data=KAES by AES GCM with sess_key
echo "(3) Encrypt data=KAES by AES-256-GCM with sess_key"
echo ""

TEST_DECRYPT=0
KEY=$OUT_SESS_KEY
IV=build_keys/eph_IV.bin
INPUT=build_keys/KAES.bin
OUTPUT=out/KAES_encrypted.bin
AUTH=out/KAES_auth_tag.bin

if [ ! -f $KEY ];then
        echo "missed key file : $KEY"
        exit 1
fi

if [ ! -f $IV ];then
        echo "missed IV file : $IV"
        exit 1
fi

if [ ! -f $INPUT ];then
        echo "missed input file : $INPUT"
        exit 1
fi

# argv[1] : 0=decrypt, 1=encrypt
# argv[2] : IV (bin file)
# argv[3] : aes key (bin file)
# argv[4] : input file name
# argv[5] : output file name
# argv[6] : auth tag (bin file)
# argv[7] : debug level 0(no debug), 1(verbose)

$AESGCM_TOOL 1 $IV $KEY $INPUT $OUTPUT $AUTH

if [ "$TEST_DECRYPT" = "1" ];then
        echo "* Test decryption..."
        $AESGCM_TOOL 0 $IV $KEY $OUTPUT restore.bin $AUTH
        cmp $INPUT restore.bin
        if [ $? -eq 0 ];then
                echo "Test OK : decrypted data is equal to original data"
                rm -f restore.bin
        else
                echo "Test FAIL: decrypted data isn't equal to original data!"
                exit 1
        fi
fi
