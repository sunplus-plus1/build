echo "$0"

rm -rf out
mkdir -p out

#BIN_FILE=../bin/xboot.bin
BIN_FILE=$1
# let xboot.bin size be 8-byte aligned
sz=`du -sb $BIN_FILE | cut -f1` ;
printf "$BIN_FILE size = %d (hex %x)\n"  $sz $sz ;
if [ $((sz & 7)) != 0 ];then
	sz_new=$(((sz + 7) & ~7))
	printf "pad xboot bin size to %d (hex %x)\n" $sz_new $sz_new
	truncate -s $sz_new $BIN_FILE
	ls -l $BIN_FILE
fi

#TODO: add more sanity check here
