olist=`find . -name "*.o"`

CROSS=$1

cnt=0
for obj in $olist ; do
	if [ "$cnt" = "0" ];then
		${CROSS}size $obj
	else
		${CROSS}size $obj |tail -n1
	fi
	cnt=$((cnt+1))
done
