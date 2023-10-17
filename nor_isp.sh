TOP=../

export PATH=$PATH:$TOP/build/tools/isp/

X=xboot.img
U=u-boot.img
S=spi_all.bin
F=fip.img
# Partition name = file name
cp $X xboot
cp $U uboot
cp $S spi_all

# There are 3 partitions in ISPBOOOT.BIN
# xboot (64k)
# uboot (64k)
# spi_all (size of SPI-NOR)

if [ -n "$2" ]; then
	NOR_SIZE=$(($2*0x100000))
else
	NOR_SIZE=0x1000000	# default size = 16 MiB
fi

if [ "$1" = "Q645" -o "$1" = "SP7350" ]; then
	cp $F fip
	isp pack_image4nor_isp ISPBOOOT.BIN xboot uboot spi_all $NOR_SIZE fip 0x100000
	rm -f fip
elif [ "$1" = "Q628" ]; then
	isp pack_image4nor_isp ISPBOOOT.BIN xboot uboot spi_all $NOR_SIZE
fi

rm -f xboot
rm -f uboot
rm -f spi_all
