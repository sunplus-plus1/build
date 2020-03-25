
CROSS_COMPILE=$1
CONFIG=./.config

bananapi_fs2_config()
{
    # XBOOT_CONFIG=q628_Rev2_EMMC_defconfig
    # UBOOT_CONFIG=bananapi_f2s_defconfig
    # KERNEL_CONFIG=pentagram_sp7021_achip_bpi-f2s_defconfig
    # NEED_ISP=1
    # echo "XBOOT_CONFIG=${XBOOT_CONFIG}" > $CONFIG
    # echo "UBOOT_CONFIG=${UBOOT_CONFIG}" >> $CONFIG
    # echo "KERNEL_CONFIG=${KERNEL_CONFIG}" >> $CONFIG
    # echo "ROOTFS_CONFIG=v7" >> $CONFIG
    # echo "CROSS_COMPILE="$CROSS_COMPILE >> $CONFIG
    # echo "NEED_ISP="$NEED_ISP >> $CONFIG
    # echo "BOOT_FROM=EMMC" >> $CONFIG
    sed -i 's/UBOOT_CONFIG=.*/UBOOT_CONFIG=bananapi_f2s_defconfig/g' $CONFIG; \
    sed -i 's/KERNEL_CONFIG=.*/KERNEL_CONFIG=pentagram_sp7021_achip_bpi-f2s_defconfig/g' $CONFIG; \
}

bananapi_fs2_config