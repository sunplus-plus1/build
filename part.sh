TOP=../
COLOR_GREEN="\033[0;1;32;40m"
COLOR_RED="\033[0;1;31;40m"
COLOR_ORIGIN="\033[0m"
ECHO="echo -e"

OUT_FILE=ISP_UPDT.BIN

if [ -f $OUT_FILE ];then
	rm -rf $OUT_FILE
fi

export PATH=$PATH:$TOP/build/tools/isp/

read PART

isp extract4update ISPBOOOT.BIN $OUT_FILE $PART


if [ -f $OUT_FILE ]; then 
	ls -la  
	$ECHO "\n" $COLOR_GREEN "Build Finish! Image: ./out/" $OUT_FILE $COLOR_ORIGIN "\n"
else 
	$ECHO "\n" $COLOR_RED "[ISP] PART image failed! " $COLOR_ORIGIN "\n"
	exit 1 
fi 
