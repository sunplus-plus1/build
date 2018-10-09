
TOP=../
CFG=$TOP/out/part.cfg
COLOR_GREEN="\033[0;1;32;40m"
COLOR_RED="\033[0;1;31;40m"
COLOR_ORIGIN="\033[0m"

#OUT_PATH=

OUT_FILE=ISP_UPDT.BIN

if [ -f $OUT_FILE ];then
	rm -rf $OUT_FILE
fi

export PATH=$PATH:$TOP/build/tools/isp/

if [ -f $CFG ];then
	. $CFG
else
	echo $COLOR_RED part.cfg nout found $COLOR_ORIGIN
	exit 1
fi

TYPE=$en_type

INPUT=$input_pat

read PART

case "$TYPE" in
	1)
	echo $COLOR_GREEN Mode : aeskey none $COLOR_ORIGIN
	isp extract4update aes_none ISPBOOOT.BIN $OUT_FILE $PART
	;;
	2)
	echo $COLOR_GREEN Mode : aeskey random $COLOR_ORIGIN
	isp extract4update aes_random ISPBOOOT.BIN $OUT_FILE $PART
	;;
	3)
	echo $COLOR_GREEN Mode : aeskey from string $COLOR_ORIGIN
	isp extract4update $INPUT ISPBOOOT.BIN $OUT_FILE $PART
	;;
	4)
	if [ -f $INPUT -a "${INPUT##*.}" = "bin" ];then
	echo $COLOR_GREEN Mode : aeskey from binary $COLOR_ORIGIN
	isp extract4update 'xxd -l 16 -ps $INPUT' ISPBOOOT.BIN $OUT_FILE $PART
	else
	echo $COLOR_RED $INPUT not found or not a binary file $COLOR_ORIGIN
	fi
	;;
	5)
	if [ -f $INPUT -a "${INPUT##*.}" = "txt" ];then
	echo $COLOR_GREEN Mode : aeskey from text $COLOR_ORIGIN
	isp extract4update 'cat $INPUT' ISPBOOOT.BIN $OUT_FILE $PART
	else
	echo $COLOR_RED $INPUT not found or not a text file $COLOR_ORIGIN
	fi
	;;
	*)
	echo $COLOR_RED $INPUT"Error: Unknow number!!"$COLOR_ORIGIN
	exit 1
esac

if [ -f $OUT_FILE ]; then 
	ls -la  
	echo "\n" $COLOR_GREEN " Build FInish!!! see ./out/"$OUT_FILE $COLOR_ORIGIN "\n"
else 
	echo "\n" $COLOR_RED " [ISP] PART image fail. " $COLOR_ORIGIN "\n"
	exit 1 
fi 
