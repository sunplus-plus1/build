echo "$0"

source sb_info.sh_inc

# arg1 : 1=test decryption
TEST_DECRYPT=$1

IV=build_keys/eph_IV.bin
KEY=build_keys/KAES.bin
#INPUT=../bin/xboot.bin
INPUT=$1
OUTPUT=out/body_encrypted.bin
AUTH=out/body_auth_tag.bin

if [ ! -f $IV ];then
	echo "missed IV : $IV"
	exit 1
fi

if [ ! -f $KEY ];then
	echo "missed Key : $KEY"
	exit 1
fi

if [ ! -f $INPUT ];then
	echo "missed input : $INPUT"
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
