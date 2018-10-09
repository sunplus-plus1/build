TOP=../

export PATH=$PATH:$TOP/build/tools/isp/

X=xboot.img
U=u-boot.img
K=uImage 

cp $X xboot0
cp $U uboot0
cp $X xboot1
cp $U uboot1
cp $U uboot2
cp $K kernel

isp pack_image ISPBOOOT.BIN \
	xboot0 uboot0 \
	xboot1 0x100000 \
	uboot1 0x100000 \
	uboot2 0x100000 \
	env 0x80000 \
	env_redund 0x80000 \
	dtb 0x10000 \
	kernel 0xa00000 \
	
rm -rf xboot0
rm -rf uboot0
rm -rf xboot1
rm -rf uboot1
rm -rf uboot2
rm -rf kernel
rm -rf dtb
rm -rf env
rm -rf env_redund 

