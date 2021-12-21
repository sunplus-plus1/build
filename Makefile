##########################################################################
#                                                                        #
#          Copyright (c) 2016 by Sunplus Technology Co., Ltd.            #
#                                                                        #
#  This software is copyrighted by and is the property of Sunplus        #
#  Technology Co., Ltd.                                                  #
#  All rights are reserved by Sunplus Technology Co., Ltd.               #
#  This software may only be used in accordance with the corresponding   #
#  license agreement. Any unauthorized use, duplication, distribution,   #
#  or disclosure of this software is expressly forbidden.                #
#                                                                        #
#  This Copyright notice MUST not be removed or modified without prior   #
#  written consent of Sunplus Technology Co., Ltd.                       #
#                                                                        #
#  Sunplus Technology Co., Ltd. reserves the right to modify this        #
#  software without notice.                                              #
#                                                                        #
#  Sunplus Technology Co., Ltd.                                          #
#  19, Innovation First Road                                             #
#  Hsinchu Science Park, Taiwan 30076                                    #
#                                                                        #
##########################################################################
TOPDIR = $(abspath .)
SHELL := sh
include ./build/Makefile.tls
include ./build/color.mak
sinclude ./.config
sinclude ./.hwconfig

TOOLCHAIN_V7_PATH = $(TOPDIR)/crossgcc/arm-linux-gnueabihf/bin
TOOLCHAIN_V5_PATH = $(TOPDIR)/crossgcc/armv5-eabi--glibc--stable/bin
TOOLCHAIN_NONOS_PATH = $(TOPDIR)/crossgcc/gcc-arm-9.2-2019.12-x86_64-arm-none-eabi/bin
TOOLCHAIN_RISCV_PATH = $(TOPDIR)/crossgcc/riscv64-sifive-linux-gnu/bin

CROSS_V7_COMPILE = $(TOOLCHAIN_V7_PATH)/arm-linux-gnueabihf-
CROSS_V5_COMPILE = $(TOOLCHAIN_V5_PATH)/armv5-glibc-linux-
CROSS_NONOS_COMPILE = $(TOOLCHAIN_NONOS_PATH)/arm-none-eabi-
CROSS_RISCV_COMPILE = $(TOOLCHAIN_RISCV_PATH)/riscv64-sifive-linux-gnu-
CROSS_RISCV_UNKNOWN_COMPILE = $(TOPDIR)/crossgcc/riscv64-unknown-elf/bin/riscv64-unknown-elf-
CROSS_ARM64_COMPILE = $(TOPDIR)/crossgcc/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-
CROSS_ARM64_XBOOT_COMPILE = $(TOPDIR)/crossgcc/gcc-arm-9.2-2019.12-x86_64-arm-none-eabi/bin/arm-none-eabi-

NEED_ISP ?= 0
ZEBU_RUN ?= 0
BOOT_FROM ?= EMMC
IS_ASSIGN_DTB ?= 0
BOOT_CHIP ?= C_CHIP
CHIP ?= Q628
ZMEM ?= 0
SECURE ?= 0
ENCRYPTION ?= 0
SB_FLAG = `expr $(SECURE) + $(ENCRYPTION) \* 2 `

BOOT_NONOS_FROM_OPENAMP ?= 1
BOOT_KERNEL_FROM_TFTP ?= 0
TFTP_SERVER_IP ?=
TFTP_SERVER_PATH ?=
BOARD_MAC_ADDR ?=
USER_NAME ?=

CONFIG_ROOT = ./.config
HW_CONFIG_ROOT = ./.hwconfig
ISP_SHELL = isp.sh
NOR_ISP_SHELL = nor_isp.sh
PART_SHELL = part.sh
SDCARD_BOOT_SHELL = sdcard_boot.sh

BUILD_PATH = build
XBOOT_PATH = boot/xboot
UBOOT_PATH = boot/uboot
LINUX_PATH = linux/kernel
ROOTFS_PATH = linux/rootfs
NONOS_B_PATH = nonos/Bchip-non-os
IPACK_PATH = ipack
OUT_PATH = out
SECURE_HSM_PATH = $(TOPDIR)/$(BUILD_PATH)/tools/secure_hsm/secure
FREERTOS_PATH = $(IPACK_PATH)
TFA_PATH = boot/trusted-firmware-a
KERNELRELEASE = $(shell cat $(LINUX_PATH)/include/config/kernel.release 2> /dev/null)

XBOOT_BIN = xboot.img
UBOOT_BIN = u-boot.img
KERNEL_BIN = uImage
DTB = dtb
VMLINUX = vmlinux
ROOTFS_DIR = $(ROOTFS_PATH)/initramfs/disk
ROOTFS_IMG = rootfs.img
NONOS_B_IMG = rom.img
FREERTOS_IMG = freertos.img

CROSS_COMPILE_FOR_XBOOT =$(CROSS_V5_COMPILE)
CROSS_COMPILE_FOR_LINUX =$(CROSS_V7_COMPILE)

ifeq ($(CHIP),I143)
CROSS_COMPILE_FOR_XBOOT =$(CROSS_RISCV_UNKNOWN_COMPILE)
else ifeq ($(ARCH),arm64)
CROSS_COMPILE_FOR_XBOOT =$(CROSS_ARM64_XBOOT_COMPILE)
endif

ifeq ($(ARCH),riscv)
CROSS_COMPILE_FOR_LINUX =$(CROSS_RISCV_COMPILE)
else ifeq ($(ARCH),arm64)
CROSS_COMPILE_FOR_LINUX =$(CROSS_ARM64_COMPILE)
KERNEL_ARM64_BIN = Image.gz
endif

CROSS_COMPILE_FOR_ROOTFS =$(CROSS_COMPILE_FOR_LINUX)
ifeq ($(ROOTFS_CONFIG),v5)
CROSS_COMPILE_FOR_ROOTFS =$(CROSS_V5_COMPILE)
endif

ARCH_XBOOT = arm
ifeq ($(CHIP),I143)
ARCH_XBOOT = riscv
endif
ARCH_UBOOT = $(ARCH_XBOOT)

IS_I143_RISCV ?= 0
ifeq ($(CHIP),I143)
ifeq ($(ARCH),riscv)
IS_I143_RISCV = 1
endif
endif

ifeq ($(CHIP),Q645)
XBOOT_LPDDR4_MAX = $$((160 * 1024))
endif

SDCARD_BOOT_MODE ?= 0
ifeq ($(CHIP),I143)
SDCARD_BOOT_MODE = 1
else ifeq ($(CHIP),Q645)
SDCARD_BOOT_MODE = 2
endif

# xboot uses name field of u-boot header to differeciate between C-chip boot image
# and P-chip boot image. If name field has prefix "uboot_B", it boots from P chip.
IS_P_CHIP ?= 0
ifeq ("$(BOOT_CHIP)", "C_CHIP")
img_name = "uboot_pentagram_board"
else
img_name = "uboot_B_pentagram_board"
IS_P_CHIP = 1
endif

ifeq ($(BOOT_FROM),SPINOR)
	SPINOR = 1
else
	SPINOR = 0
endif

ifeq ($(BOOT_FROM),NOR_JFFS2)
	NOR_JFFS2 = 1
else
	NOR_JFFS2 = 0
endif

# 0: uImage, 1: qk_boot image (uncompressed)
USE_QK_BOOT=0

SPI_BIN = spi_all.bin
DOWN_TOOL = down_32M.exe
SECURE_PATH ?=

.PHONY: all xboot uboot kenel rom clean distclean config init check rootfs info nonos freertos toolchain
.PHONY: dtb spirom isp tool_isp kconfig uconfig xconfig

# rootfs image is created by :
# make initramfs -> re-create initial disk/
# make kernel    -> install kernel modules to disk/lib/modules/
# make rootfs    -> create rootfs image from disk/
all: check
	@$(MAKE) xboot
	@$(MAKE) dtb
	@$(MAKE) uboot
	@if [ "$(IS_I143_RISCV)" = "1" -o "$(CHIP)" = "Q645" ]; then \
		$(MAKE) freertos; \
	else \
		$(MAKE) nonos; \
	fi
	@$(MAKE) kernel
	@$(MAKE) rootfs
	@$(MAKE) rom

freertos:
	@if [ "$(CHIP)" = "Q645" ]; then \
		$(MAKE) -C freertos/q645; \
	else \
		$(MAKE) -C freertos CROSS_COMPILE=$(CROSS_COMPILE_FOR_XBOOT); \
		if [ "$(NEED_ISP)" = '1' ]; then \
			if [ "$(IS_P_CHIP)" = "1" ]; then \
				$(CP) -f $(TOPDIR)/freertos/build/FreeRTOS-simple.elf $(TOPDIR)/$(IPACK_PATH)/bin;\
				$(CROSS_COMPILE_FOR_XBOOT)objcopy -O binary -S $(TOPDIR)/$(IPACK_PATH)/bin/FreeRTOS-simple.elf $(TOPDIR)/$(IPACK_PATH)/bin/freertos.bin;\
				cd $(IPACK_PATH); ./add_uhdr.sh freertos-`date +%Y%m%d-%H%M%S` $(TOPDIR)/$(IPACK_PATH)/bin/freertos.bin $(TOPDIR)/$(IPACK_PATH)/bin/freertos.img riscv;\
			fi; \
		fi; \
	fi
#xboot build
xboot: check
	@$(MAKE) ARCH=$(ARCH_XBOOT) $(MAKE_JOBS) -C $(XBOOT_PATH) CROSS=$(CROSS_COMPILE_FOR_XBOOT) SECURE=$(SECURE) all
	@$(MAKE) secure SECURE_PATH=xboot
#tfa build
tfa: check
	@if [ ! -f $(TOPDIR)/$(UBOOT_PATH)/uboot_temp.bin ]; then \
		$(ECHO) $(COLOR_YELLOW) "### make uboot first !!###"$(COLOR_ORIGIN) ;\
		exit 1; \
	fi;
	@$(MAKE) -f $(TFA_PATH)/q645.mk CROSS=$(CROSS_ARM64_COMPILE) build
	@$(TOPDIR)/build/tools/add_uhdr.sh "u_boot" $(TOPDIR)/$(UBOOT_PATH)/uboot_temp.bin $(TOPDIR)/$(UBOOT_PATH)/$(UBOOT_BIN) $(ARCH)
	@cat $(TOPDIR)/$(UBOOT_PATH)/$(UBOOT_BIN) $(TFA_PATH)/build/bl31.img > $(TOPDIR)/$(UBOOT_PATH)/u-boot.bin
	@$(MAKE) secure SECURE_PATH=uboot
#uboot build
uboot: check
	@if [ $(BOOT_KERNEL_FROM_TFTP) -eq 1 ]; then \
		$(MAKE) ARCH=$(ARCH_UBOOT) $(MAKE_JOBS) -C $(UBOOT_PATH) all CROSS_COMPILE=$(CROSS_COMPILE_FOR_LINUX) EXT_DTB=../../linux/kernel/dtb  \
			KCPPFLAGS="-DBOOT_KERNEL_FROM_TFTP=$(BOOT_KERNEL_FROM_TFTP) -DTFTP_SERVER_IP=$(TFTP_SERVER_IP) \
			-DBOARD_MAC_ADDR=$(BOARD_MAC_ADDR) -DUSER_NAME=$(USER_NAME)"; \
	else \
		$(MAKE) ARCH=$(ARCH_UBOOT) $(MAKE_JOBS) -C $(UBOOT_PATH) all CROSS_COMPILE=$(CROSS_COMPILE_FOR_LINUX) EXT_DTB=../../linux/kernel/dtb \
			KCPPFLAGS="-DSPINOR=$(SPINOR) -DNOR_JFFS2=$(NOR_JFFS2) -DCOMPILE_WITH_SECURE=$(SECURE) -DBOOT_NONOS_FROM_OPENAMP=$(BOOT_NONOS_FROM_OPENAMP)"; \
	fi
	@if [ "$(IS_I143_RISCV)" = "1" ]; then \
		$(MAKE) -C $(TOPDIR)/boot/opensbi distclean && $(MAKE) -C $(TOPDIR)/boot/opensbi FW_PAYLOAD_PATH=$(TOPDIR)/$(UBOOT_PATH)/u-boot.bin CROSS_COMPILE=$(CROSS_COMPILE_FOR_XBOOT); \
		$(CP) -f $(TOPDIR)/boot/opensbi/out/fw_payload.bin $(TOPDIR)/$(UBOOT_PATH)/u-boot.bin; \
	fi
	@if [ "$(CHIP)" = "Q645" ]; then \
		dd if=$(TOPDIR)/$(UBOOT_PATH)/u-boot.bin of=$(TOPDIR)/$(UBOOT_PATH)/uboot_temp.bin  bs=1 skip=64 conv=notrunc 2>/dev/null ;\
		img_sz=`du -sb $(TOPDIR)/$(UBOOT_PATH)/uboot_temp.bin | cut -f1` ; add_zero=$$((4-img_sz%4));\
		dd if=/dev/zero of=$(TOPDIR)/$(UBOOT_PATH)/uboot_temp.bin  bs=1 seek=$$((img_sz)) count=$$((add_zero)) conv=notrunc 2>/dev/null ;\
		$(MAKE) tfa;\
	else \
		$(TOPDIR)/build/tools/add_uhdr.sh $(img_name) $(TOPDIR)/$(UBOOT_PATH)/u-boot.bin $(TOPDIR)/$(UBOOT_PATH)/$(UBOOT_BIN) $(ARCH) ;\
		img_sz=`du -sb $(TOPDIR)/$(UBOOT_PATH)/$(UBOOT_BIN) | cut -f1` ; \
		printf "size: %d (hex %x)\n" $$img_sz $$img_sz ;\
		$(MAKE) secure SECURE_PATH=uboot ;\
	fi

#kernel build
kernel: check
	@$(MAKE_ARCH) $(MAKE_JOBS) -C $(LINUX_PATH) all CROSS_COMPILE=$(CROSS_COMPILE_FOR_LINUX)
	@if [ "$(IS_I143_RISCV)" = "1" ]; then \
		cd $(IPACK_PATH); ./add_uhdr.sh linux-`date +%Y%m%d-%H%M%S` $(TOPDIR)/$(LINUX_PATH)/arch/$(ARCH)/boot/Image.gz $(TOPDIR)/$(LINUX_PATH)/arch/$(ARCH)/boot/$(KERNEL_BIN) $(ARCH) 0xA0200000 0xA0200000 kernel; \
	else \
		$(RM) -rf $(ROOTFS_DIR)/lib/modules/; \
		$(MAKE_ARCH) $(MAKE_JOBS) -C $(LINUX_PATH) modules_install INSTALL_MOD_PATH=../../$(ROOTFS_DIR) CROSS_COMPILE=$(CROSS_COMPILE_FOR_LINUX); \
		$(RM) $(ROOTFS_DIR)/lib/modules/$(KERNELRELEASE)/build; \
		$(RM) $(ROOTFS_DIR)/lib/modules/$(KERNELRELEASE)/source; \
		if [ "$(CHIP)" = "Q645" ]; then \
			$(RM) -f $(LINUX_PATH)/arch/$(ARCH)/boot/$(KERNEL_ARM64_BIN); \
			$(MAKE_ARCH) $(MAKE_JOBS) -C $(LINUX_PATH) $(KERNEL_ARM64_BIN) V=0 CROSS_COMPILE=$(CROSS_COMPILE_FOR_LINUX); \
		else \
			$(RM) -f $(LINUX_PATH)/arch/$(ARCH)/boot/$(KERNEL_BIN); \
			$(MAKE_ARCH) $(MAKE_JOBS) -C $(LINUX_PATH) $(KERNEL_BIN) V=0 CROSS_COMPILE=$(CROSS_COMPILE_FOR_LINUX); \
		fi; \
	fi
	@$(MAKE) secure SECURE_PATH=kernel;

nonos:
	@$(MAKE) -C $(NONOS_B_PATH) CROSS=$(CROSS_NONOS_COMPILE) BOOT_NONOS_FROM_OPENAMP=$(BOOT_NONOS_FROM_OPENAMP)
	@echo "Wrapping rom.bin -> rom.img..."
# for A:
#	$(TOPDIR)/build/tools/add_uhdr.sh uboot $(NONOS_B_PATH)/bin/rom.bin $(NONOS_B_PATH)/bin/rom.img arm 0x200040 0x200040
# for B:
	@if [ "$(BOOT_NONOS_FROM_OPENAMP)" = "0" ]; then \
		$(RM) -f linux/rootfs/initramfs/disk/lib/firmware/rom ; \
		$(TOPDIR)/build/tools/add_uhdr.sh uboot $(NONOS_B_PATH)/bin/rom.bin $(NONOS_B_PATH)/bin/rom.img arm 0x10040 0x10040; \
		sz=`du -sb $(NONOS_B_PATH)/bin/rom.img|cut -f1`; printf "rom size = %d (hex %x)\n" $$sz $$sz; \
	else \
		echo "copy $(NONOS_B_PATH)/bin/rom to rootfs/lib/firmware " ; \
		$(CP) $(NONOS_B_PATH)/bin/rom linux/rootfs/initramfs/disk/lib/firmware ; \
	fi


hsm_init:
	@if [ "$(CHIP)" = "Q645" ]; then \
		cd $(SECURE_HSM_PATH); ./gen_HSM_keys.sh ; \
	fi

clean:
	@$(MAKE_ARCH) -C $(NONOS_B_PATH) $@
	@$(MAKE) -C freertos/q645 $@
	@$(MAKE) ARCH=$(ARCH_XBOOT) -C $(XBOOT_PATH) CROSS=$(CROSS_COMPILE_FOR_XBOOT) $@
	@$(MAKE) -f $(TFA_PATH)/q645.mk CROSS=$(CROSS_ARM64_COMPILE) $@
	@$(MAKE_ARCH) -C $(UBOOT_PATH) $@
	@$(MAKE_ARCH) -C $(LINUX_PATH) mrproper
	@$(MAKE_ARCH) -C $(ROOTFS_PATH) $@
	@$(MAKE) -C $(TOPDIR)/$(BUILD_PATH)/tools/isp $@
	@$(RM) -rf $(OUT_PATH)

distclean: clean
	@$(MAKE) ARCH=$(ARCH_XBOOT) -C $(XBOOT_PATH) CROSS=$(CROSS_COMPILE_FOR_XBOOT) $@
	@$(MAKE_ARCH) -C $(UBOOT_PATH) $@
	@$(MAKE_ARCH) -C $(LINUX_PATH) $@
	@$(RM) -f $(CONFIG_ROOT)
	@$(RM) -f $(HW_CONFIG_ROOT)

__config: hsm_init
	@if [ -z $(HCONFIG) ]; then \
		$(RM) -f $(HW_CONFIG_ROOT); \
	fi
	$(eval CROSS_COMPILE=$(shell cat $(CONFIG_ROOT) | grep 'CROSS_COMPILE=' | sed 's/CROSS_COMPILE=//g'))
	$(eval ARCH=$(shell cat $(CONFIG_ROOT) | grep 'ARCH=' | sed 's/ARCH=//g'))
	$(eval CHIP=$(shell cat $(CONFIG_ROOT) | grep 'CHIP=' | sed 's/CHIP=//g'))
	@$(MAKE) -C $(XBOOT_PATH) ARCH=$(ARCH_XBOOT) CROSS=$(CROSS_COMPILE_FOR_XBOOT) $(shell cat $(CONFIG_ROOT) | grep 'XBOOT_CONFIG=' | sed 's/XBOOT_CONFIG=//g')
	@$(MAKE_ARCH) -C $(UBOOT_PATH) clean
	@$(MAKE_ARCH) -C $(UBOOT_PATH) CROSS_COMPILE=$(CROSS_COMPILE_FOR_LINUX) $(shell cat $(CONFIG_ROOT) | grep 'UBOOT_CONFIG=' | sed 's/UBOOT_CONFIG=//g')
	@$(MAKE_ARCH) -C $(LINUX_PATH) mrproper
	@$(MAKE_ARCH) -C $(LINUX_PATH) CROSS_COMPILE=$(CROSS_COMPILE_FOR_LINUX) $(shell cat $(CONFIG_ROOT) | grep 'KERNEL_CONFIG=' | sed 's/KERNEL_CONFIG=//g')
	@$(MAKE_ARCH) initramfs
	@$(MKDIR) -p $(OUT_PATH)
	@$(MAKE) -C $(TOPDIR)/$(BUILD_PATH)/tools/isp clean
	@$(RM) -f $(TOPDIR)/$(OUT_PATH)/$(ISP_SHELL) $(TOPDIR)/$(OUT_PATH)/$(PART_SHELL) $(TOPDIR)/$(OUT_PATH)/$(NOR_ISP_SHELL)
	@$(LN) -s $(TOPDIR)/$(BUILD_PATH)/$(ISP_SHELL) $(TOPDIR)/$(OUT_PATH)/$(ISP_SHELL)
	@$(LN) -s $(TOPDIR)/$(BUILD_PATH)/$(NOR_ISP_SHELL) $(TOPDIR)/$(OUT_PATH)/$(NOR_ISP_SHELL)
	@$(LN) -s $(TOPDIR)/$(BUILD_PATH)/$(PART_SHELL) $(TOPDIR)/$(OUT_PATH)/$(PART_SHELL)
	@$(CP) -f $(IPACK_PATH)/bin/$(DOWN_TOOL) $(OUT_PATH)
	@$(ECHO) $(COLOR_YELLOW)"platform info :"$(COLOR_ORIGIN)
	$(eval ZMEM=$(shell cat $(CONFIG_ROOT) | grep 'ZMEM=' | sed 's/ZMEM=//g'))
	@$(MAKE) info

config: init
	@$(MAKE) __config

hconfig:
	@./build/hconfig.sh $(CROSS_V7_COMPILE)
	$(MAKE) config HCONFIG="1"

dtb: check
	$(eval LINUX_DTB=$(shell cat $(CONFIG_ROOT) | grep 'LINUX_DTB=' | sed 's/LINUX_DTB=//g').dtb)

	@if [ $(IS_ASSIGN_DTB) -eq 1 ]; then \
		$(MAKE_ARCH) -C $(LINUX_PATH) $(HW_DTB) CROSS_COMPILE=$(CROSS_COMPILE_FOR_LINUX); \
		$(LN) -fs arch/$(ARCH)/boot/dts/$(HW_DTB) $(LINUX_PATH)/dtb; \
	else \
		$(MAKE_ARCH) -C $(LINUX_PATH) $(LINUX_DTB) CROSS_COMPILE=$(CROSS_COMPILE_FOR_LINUX); \
		if [ $$? -ne 0 ]; then \
			exit 1; \
		fi; \
		$(LN) -fs arch/$(ARCH)/boot/dts/$(LINUX_DTB) $(LINUX_PATH)/dtb; \
	fi

spirom_isp: check tool_isp
	@if [ -f $(XBOOT_PATH)/bin/$(XBOOT_BIN) ]; then \
		$(CP) -f $(XBOOT_PATH)/bin/$(XBOOT_BIN) $(OUT_PATH); \
	else \
		$(ECHO) $(COLOR_YELLOW)$(XBOOT_BIN)" doesn't exist."$(COLOR_ORIGIN); \
		exit 1; \
	fi
	@if [ -f $(UBOOT_PATH)/$(UBOOT_BIN) ]; then \
		$(CP) -f $(UBOOT_PATH)/$(UBOOT_BIN) $(OUT_PATH); \
	else \
		$(ECHO) $(COLOR_YELLOW)$(UBOOT_BIN)" doesn't exist."$(COLOR_ORIGIN); \
		exit 1; \
	fi
	@cd out/; ./$(NOR_ISP_SHELL)
	@$(RM) -f $(OUT_PATH)/$(XBOOT_BIN)
	@$(RM) -f $(OUT_PATH)/$(UBOOT_BIN)

spirom: check
	@if [ $(BOOT_KERNEL_FROM_TFTP) -eq 1 ]; then \
		$(MAKE_ARCH) -C $(IPACK_PATH) all ZEBU_RUN=$(ZEBU_RUN) BOOT_KERNEL_FROM_TFTP=$(BOOT_KERNEL_FROM_TFTP) \
		TFTP_SERVER_PATH=$(TFTP_SERVER_PATH) CHIP=$(CHIP); \
	else \
		$(MAKE_ARCH) -C $(IPACK_PATH) all ZEBU_RUN=$(ZEBU_RUN) CHIP=$(CHIP) NOR_JFFS2=$(NOR_JFFS2); \
	fi
	@if [ -f $(IPACK_PATH)/bin/$(SPI_BIN) -a "$(ZEBU_RUN)" = "0" ]; then \
		$(ECHO) $(COLOR_YELLOW)"Copy "$(SPI_BIN)" to out folder."$(COLOR_ORIGIN); \
		$(CP) -f $(IPACK_PATH)/bin/$(SPI_BIN) $(OUT_PATH); \
	fi

tool_isp:
	@$(MAKE) -C $(TOPDIR)/$(BUILD_PATH)/tools/isp FREERTOS=$(IS_I143_RISCV) CHIP=$(CHIP)

isp: check tool_isp
	@if [ -f $(XBOOT_PATH)/bin/$(XBOOT_BIN) ]; then \
		$(CP) -f $(XBOOT_PATH)/bin/$(XBOOT_BIN) $(OUT_PATH); \
		$(ECHO) $(COLOR_YELLOW)"Copy "$(XBOOT_BIN)" to out folder."$(COLOR_ORIGIN); \
	else \
		$(ECHO) $(COLOR_YELLOW)$(XBOOT_BIN)" doesn't exist."$(COLOR_ORIGIN); \
		exit 1; \
	fi
	@if [ -f $(UBOOT_PATH)/$(UBOOT_BIN) ]; then \
		$(CP) -f $(UBOOT_PATH)/$(UBOOT_BIN) $(OUT_PATH); \
		$(ECHO) $(COLOR_YELLOW)"Copy "$(UBOOT_BIN)" to out folder."$(COLOR_ORIGIN); \
	else \
		$(ECHO) $(COLOR_YELLOW)$(UBOOT_BIN)" doesn't exist."$(COLOR_ORIGIN); \
		exit 1; \
	fi

	@if [ "$(IS_I143_RISCV)" = "1" ]; then \
		if [ "$(IS_P_CHIP)" = "1" ]; then \
			if [ -f $(FREERTOS_PATH)/bin/$(FREERTOS_IMG) ]; then \
				$(CP) -f $(FREERTOS_PATH)/bin/$(FREERTOS_IMG) $(OUT_PATH)/a926.img; \
				$(ECHO) $(COLOR_YELLOW)"Copy freertos.img to out folder."$(COLOR_ORIGIN); \
			fi; \
		fi; \
	else \
		if [ -f $(NONOS_B_PATH)/bin/$(NONOS_B_IMG) ]; then \
			$(CP) -f $(NONOS_B_PATH)/bin/$(NONOS_B_IMG) $(OUT_PATH)/a926.img; \
			$(ECHO) $(COLOR_YELLOW)"Copy nonos img to out folder."$(COLOR_ORIGIN); \
		fi; \
	fi
	@if [ -f $(LINUX_PATH)/$(VMLINUX) ]; then \
		if [ "$(USE_QK_BOOT)" = "1" ]; then \
			$(CP) -f $(LINUX_PATH)/$(VMLINUX) $(OUT_PATH); \
			$(ECHO) $(COLOR_YELLOW)"Copy "$(VMLINUX)" to out folder."$(COLOR_ORIGIN); \
			$(CROSS_COMPILE_FOR_LINUX)objcopy -O binary -S $(OUT_PATH)/$(VMLINUX) $(OUT_PATH)/$(VMLINUX).bin; \
			cd $(IPACK_PATH); \
			./add_uhdr.sh linux-`date +%Y%m%d-%H%M%S` $(TOPDIR)/$(OUT_PATH)/$(VMLINUX).bin $(TOPDIR)/$(OUT_PATH)/$(KERNEL_BIN) 0x308000 0x308000; \
			cd $(TOPDIR); \
			if [ -f $(OUT_PATH)/$(KERNEL_BIN) ]; then \
				$(ECHO) $(COLOR_YELLOW)"Add uhdr in "$(KERNEL_BIN)"."$(COLOR_ORIGIN); \
			else \
				$(ECHO) $(COLOR_YELLOW)"Gen "$(KERNEL_BIN)" fail."$(COLOR_ORIGIN); \
			fi; \
		else \
			if [ "$(CHIP)" = "Q645" ]; then \
				if [ "$(ZEBU_RUN)" = "1" ]; then \
					$(CP) -vf $(LINUX_PATH)/arch/$(ARCH)/boot/Image $(LINUX_PATH)/arch/$(ARCH)/boot/$(KERNEL_BIN); \
				fi; \
			fi;\
			$(CP) -vf $(LINUX_PATH)/arch/$(ARCH)/boot/$(KERNEL_BIN) $(OUT_PATH); \
		fi; \
	else \
		$(ECHO) $(COLOR_YELLOW)$(VMLINUX)" doesn't exist."$(COLOR_ORIGIN); \
		exit 1; \
	fi
	@if [ -f $(LINUX_PATH)/$(DTB) ]; then \
		if [ "$(USE_QK_BOOT)" = "1" ]; then \
			$(CP) -f $(LINUX_PATH)/$(DTB) $(OUT_PATH)/$(DTB).raw ; \
			cd $(IPACK_PATH); \
			pwd && pwd && pwd; \
			./add_uhdr.sh dtb-`date +%Y%m%d-%H%M%S` ../$(OUT_PATH)/$(DTB).raw ../$(OUT_PATH)/$(DTB) 0x000000 0x000000; \
			cd .. ; \
		else \
			$(CP) -vf $(LINUX_PATH)/$(DTB) $(OUT_PATH)/$(DTB) ; \
		fi; \
		$(ECHO) $(COLOR_YELLOW)"Copy "$(DTB)" to out folder."$(COLOR_ORIGIN); \
	else \
		$(ECHO) $(COLOR_YELLOW)$(DTB)" doesn't exist."$(COLOR_ORIGIN); \
		exit 1; \
	fi
	@if [ "$(BOOT_FROM)" != "SDCARD" ] && [ "$(BOOT_FROM)" != "USB" ]; then  \
		if [ -f $(ROOTFS_PATH)/$(ROOTFS_IMG) ]; then \
			$(ECHO) $(COLOR_YELLOW)"Copy "$(ROOTFS_IMG)" to out folder."$(COLOR_ORIGIN); \
			$(CP) -vf $(ROOTFS_PATH)/$(ROOTFS_IMG) $(OUT_PATH)/ ;\
		else \
			$(ECHO) $(COLOR_YELLOW)$(ROOTFS_IMG)" doesn't exist."$(COLOR_ORIGIN); \
			exit 1; \
		fi \
	fi
	@cd out/; ./$(ISP_SHELL) $(BOOT_FROM) $(CHIP)

	@if [ "$(BOOT_FROM)" = "SDCARD" ]; then  \
		$(ECHO) $(COLOR_YELLOW) "Generating image for SD card..." $(COLOR_ORIGIN); \
		cd build/tools/sdcard_boot; ./$(SDCARD_BOOT_SHELL) $(SDCARD_BOOT_MODE); \
	fi

part:
	@$(ECHO) $(COLOR_YELLOW) "Please enter the Partition NAME!!!" $(COLOR_ORIGIN)
	@cd out; ./$(PART_SHELL)

secure:
	@if [ "$(SECURE_PATH)" = "xboot" ]; then \
		$(ECHO) $(COLOR_YELLOW) "###xboot add sign data ####!!!" $(COLOR_ORIGIN) ;\
		if [ ! -f $(XBOOT_PATH)/bin/xboot.bin ]; then \
			exit 1; \
		fi; \
		if [ "$(CHIP)" = "Q645" ]; then \
			if [ "$(SECURE)" = "1" ]; then \
				cd $(SECURE_HSM_PATH); ./clr_out.sh ; \
				./build_inputfile_sb.sh $(TOPDIR)/$(XBOOT_PATH)/bin/xboot.bin $(SB_FLAG);\
				cp -f $(SECURE_HSM_PATH)/out/outfile_sb.bin $(TOPDIR)/$(XBOOT_PATH)/bin/xboot.bin ; \
			fi ;\
			cd $(TOPDIR)/$(XBOOT_PATH); \
			bash ./add_xhdr.sh ./bin/xboot.bin ./bin/$(XBOOT_BIN) $(SECURE) ; \
			make size_check || exit 1; \
			mv ./bin/$(XBOOT_BIN) ./bin/$(XBOOT_BIN).orig ; \
			cat ./bin/$(XBOOT_BIN).orig ./bin/lpddr4_pmu_train_imem.img ./bin/lpddr4_pmu_train_dmem.img ./bin/lpddr4_2d_pmu_train_imem.img ./bin/lpddr4_2d_pmu_train_dmem.img > ./bin/$(XBOOT_BIN) ; \
			sz=`du -sb ./bin/$(XBOOT_BIN) | cut -f1` ; \
			printf "$(XBOOT_BIN) (+ lpddr4 fw) size = %d (hex %x)\n" $$sz $$sz ; \
			if [ $$sz -gt $(XBOOT_LPDDR4_MAX) ]; then \
				echo "$(XBOOT_BIN) (+ lpddr4 fw) size limit is $(XBOOT_LPDDR4_MAX). Please reduce its size.\n" ; \
				exit 1; \
			fi; \
		else \
			$(SHELL) ./build/tools/secure_sign/gen_signature.sh $(XBOOT_PATH)/bin xboot.bin 0 ;\
			cd $(XBOOT_PATH); \
			/bin/bash ./add_xhdr.sh ./bin/xboot.bin ./bin/$(XBOOT_BIN) 1 ; \
			make size_check || exit 1; \
		fi; \
	elif [ "$(SECURE_PATH)" = "uboot" ]; then \
		$(ECHO) $(COLOR_YELLOW) "###uboot add sign data ####!!!" $(COLOR_ORIGIN) ;\
		if [ ! -f $(UBOOT_PATH)/$(UBOOT_BIN) ]; then \
			exit 1; \
		fi; \
		if [ "$(CHIP)" = "Q645" ]; then \
			if [ "$(SECURE)" = "1" ]; then \
				cd $(SECURE_HSM_PATH); ./clr_out.sh ; \
				./build_inputfile_sb.sh $(TOPDIR)/$(UBOOT_PATH)/u-boot.bin  $(SB_FLAG);\
				cp -f $(SECURE_HSM_PATH)/out/outfile_sb.bin $(TOPDIR)/$(UBOOT_PATH)/u-boot.bin; \
			fi; \
			cd $(TOPDIR) ; $(TOPDIR)/build/tools/add_uhdr.sh $(img_name) $(TOPDIR)/$(UBOOT_PATH)/u-boot.bin $(TOPDIR)/$(UBOOT_PATH)/$(UBOOT_BIN) $(ARCH) ;\
		else \
			$(SHELL) ./build/tools/secure_sign/gen_signature.sh $(UBOOT_PATH) $(UBOOT_BIN) 1 ; \
		fi; \
	elif [ "$(SECURE_PATH)" = "kernel" ]; then \
		$(ECHO) $(COLOR_YELLOW) "###kernel add sign data ####!!!" $(COLOR_ORIGIN);\
		if [ "$(CHIP)" = "Q645" ]; then \
			if [ ! -f $(LINUX_PATH)/arch/$(ARCH)/boot/Image ]; then \
				exit 1; \
			fi; \
			if [ "$(BOOT_FROM)" != "SPINOR" ] && [ "$(BOOT_FROM)" != "NOR_JFFS2" ]; then  \
				cp -f $(TOPDIR)/$(LINUX_PATH)/arch/$(ARCH)/boot/Image $(TOPDIR)/$(LINUX_PATH)/arch/$(ARCH)/boot/Image.gz; \
			fi; \
			if [ "$(SECURE)" = "1" ]; then \
				cd $(SECURE_HSM_PATH); ./clr_out.sh ; \
				./build_inputfile_sb.sh $(TOPDIR)/$(LINUX_PATH)/arch/$(ARCH)/boot/Image.gz $(SECURE); \
				cp -f $(SECURE_HSM_PATH)/out/outfile_sb.bin $(TOPDIR)/$(LINUX_PATH)/arch/$(ARCH)/boot/Image.gz; \
			fi;\
			cd $(TOPDIR)/$(IPACK_PATH); ./add_uhdr.sh linux-`date +%Y%m%d-%H%M%S` $(TOPDIR)/$(LINUX_PATH)/arch/$(ARCH)/boot/Image.gz $(TOPDIR)/$(LINUX_PATH)/arch/$(ARCH)/boot/$(KERNEL_BIN) $(ARCH) 0x0480000 0x0480000 kernel; \
		else \
			if [ ! -f $(LINUX_PATH)/arch/$(ARCH)/boot/$(KERNEL_BIN) ]; then \
				exit 1; \
			fi; \
			$(SHELL) ./build/tools/secure_sign/gen_signature.sh $(LINUX_PATH)/arch/$(ARCH)/boot $(KERNEL_BIN) 1 ;\
		fi; \
	fi

rom: check
	@if [ "$(NEED_ISP)" = '1' ]; then  \
		$(MAKE) isp; \
	else \
		$(MAKE) spirom; \
		if [ "$(ZEBU_RUN)" = "0" ]; then \
			$(MAKE) spirom_isp; \
		fi; \
	fi

mt: check
	@$(MAKE) kernel
	cp linux/application/module_test/mt2.sh $(ROOTFS_DIR)/bin
	@$(MAKE) rootfs rom

init:
	@if ! [ -f $(CROSS_COMPILE_FOR_LINUX) ]; then \
		pwd; \
		./build/dlgcc.sh; \
	fi
	@$(RM) -f $(CONFIG_ROOT)
	@./build/config.sh $(CROSS_V7_COMPILE) $(CROSS_RISCV_COMPILE)

check:
	@if ! [ -f $(CONFIG_ROOT) ]; then \
		$(ECHO) $(COLOR_YELLOW)"Please \"make config\" first."$(COLOR_ORIGIN); \
		exit 1; \
	fi

initramfs:
	@$(MAKE_ARCH) -C $(ROOTFS_PATH) CROSS=$(CROSS_COMPILE_FOR_ROOTFS) initramfs rootfs_cfg=$(ROOTFS_CONFIG) boot_from=$(BOOT_FROM) ROOTFS_CONTENT=$(ROOTFS_CONTENT)

rootfs:
ifneq ($(CHIP),Q645)
	$(RM) -f $(ROOTFS_DIR)/lib/firmware/ethosn.bin
	$(RM) -f $(ROOTFS_DIR)/lib64/libEthosNDriver.so
	$(RM) -f $(ROOTFS_DIR)/lib64/libEthosNSupport.so
endif	
	@$(MAKE_ARCH) -C $(ROOTFS_PATH) CROSS=$(CROSS_COMPILE_FOR_ROOTFS) rootfs rootfs_cfg=$(ROOTFS_CONFIG) boot_from=$(BOOT_FROM) ROOTFS_CONTENT=$(ROOTFS_CONTENT)

kconfig:
	$(MAKE_ARCH) -C $(LINUX_PATH) CROSS_COMPILE=$(CROSS_COMPILE_FOR_LINUX) menuconfig

uconfig:
	$(MAKE_ARCH) -C $(UBOOT_PATH) CROSS_COMPILE=$(CROSS_COMPILE_FOR_LINUX) menuconfig

xconfig:
	$(MAKE) ARCH=$(ARCH_XBOOT) -C $(XBOOT_PATH) CROSS=$(CROSS_COMPILE_FOR_XBOOT) menuconfig

headers:
	@KERNELRELEASE=$(shell cat $(LINUX_PATH)/include/config/kernel.release 2>/dev/null)
	@if ! [ -f $(LINUX_PATH)/.config ]; then \
		echo File \'$(LINUX_PATH)/.config\' does not exist!; \
		exit 1; \
	fi
	@if ! [ -f $(LINUX_PATH)/Module.symvers ]; then \
		echo File \'$(LINUX_PATH)/Module.symvers\' does not exist!; \
		exit 1; \
	fi
	rm -rf linux-headers-$(KERNELRELEASE)
	mkdir -p linux-headers-$(KERNELRELEASE)
	cp -f $(LINUX_PATH)/.config linux-headers-$(KERNELRELEASE)
	cp -f $(LINUX_PATH)/Module.symvers linux-headers-$(KERNELRELEASE)
	$(MAKE_ARCH) $(MAKE_JOBS) -C $(LINUX_PATH) CROSS_COMPILE=$(CROSS_COMPILE_FOR_LINUX) mrproper
	$(MAKE_ARCH) $(MAKE_JOBS) -C $(LINUX_PATH) O=../../linux-headers-$(KERNELRELEASE) CROSS_COMPILE=$(CROSS_COMPILE_FOR_LINUX) modules_prepare

info:
	@$(ECHO) "XBOOT =" $(XBOOT_CONFIG)
	@$(ECHO) "UBOOT =" $(UBOOT_CONFIG)
	@$(ECHO) "KERNEL =" $(KERNEL_CONFIG)
	@$(ECHO) "LINUX_DTB =" $(LINUX_DTB)
	@$(ECHO) "CROSS COMPILER XBOOT =" $(CROSS_COMPILE_FOR_XBOOT)
	@$(ECHO) "CROSS COMPILER LINUX =" $(CROSS_COMPILE_FOR_LINUX)
	@$(ECHO) "CROSS COMPILER ROOTFS =" $(CROSS_COMPILE_FOR_ROOTFS)
	@$(ECHO) "NEED ISP =" $(NEED_ISP)
	@$(ECHO) "ZEBU RUN =" $(ZEBU_RUN)
	@$(ECHO) "BOOT FROM =" $(BOOT_FROM)
	@$(ECHO) "BOOT CHIP =" $(BOOT_CHIP)
	@$(ECHO) "ARCH =" $(ARCH)
	@$(ECHO) "CHIP =" $(CHIP)
	@$(ECHO) "ZMEM =" $(ZMEM)
	@$(ECHO) "SECURE =" $(SECURE)
	@$(ECHO) "ENCRYPTION =" $(ENCRYPTION)
	@$(ECHO) "ROOTFS_CONTENT =" $(ROOTFS_CONTENT)

include ./build/qemu.mak

