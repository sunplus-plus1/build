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
cp $F fip
# There are 3 partitions in ISPBOOOT.BIN
# xboot (64k)
# uboot (64k)
# spi_all (size of SPI-NOR)
isp pack_image4nor_isp ISPBOOOT.BIN xboot uboot spi_all 0x1000000 fip 0x100000

rm -f xboot
rm -f uboot
rm -f spi_all
rm -f fip