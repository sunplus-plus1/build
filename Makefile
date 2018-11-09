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
TOPDIR = $(PWD)
SHELL := /bin/bash
include ./build/Makefile.tls
include ./build/color.mak
sinclude ./.config

TOOLCHAIN_V7_PATH = $(TOPDIR)/build/tools/armv7-eabihf--glibc--stable/bin
TOOLCHAIN_V5_PATH = $(TOPDIR)/build/tools/armv5-eabi--glibc--stable/bin

CROSS_V7_COMPILE = $(TOOLCHAIN_V7_PATH)/armv7hf-glibc-linux-
CROSS_V5_COMPILE = $(TOOLCHAIN_V5_PATH)/armv5-glibc-linux-

NEED_ISP ?= 0
ZEBU_RUN ?= 0

CONFIG_ROOT = ./.config
ISP_SHELL = isp.sh
PART_SHELL = part.sh

LINUX_DTB = $(shell echo $(KERNEL_CONFIG) | sed 's/_defconfig//g' | sed 's/_/-/g').dtb

BUILD_PATH = build
XBOOT_PATH = boot/xboot
UBOOT_PATH = boot/uboot
LINUX_PATH = linux/kernel
IPACK_PATH = ipack
OUT_PATH = out

XBOOT_BIN = xboot.img
UBOOT_BIN = u-boot.img
KERNEL_BIN = uImage
DTB = dtb
VMLINUX = vmlinux

# 0: uImage, 1: qk_boot image (uncompressed)
USE_QK_BOOT=0

SPI_BIN = spi_all.bin
DOWN_TOOL  = down_32M.exe

.PHONY: all xboot uboot kenel rom clean distclean config init check rootfs info
.PHONY: dtb spirom isp tool_isp

#xboot build
xboot: check
	@$(MAKE) $(MAKE_JOBS) -C $(XBOOT_PATH) all

#uboot build
uboot: check
	@$(MAKE) $(MAKE_JOBS) -C $(UBOOT_PATH) all CROSS_COMPILE=$(CROSS_COMPILE)

#kernel build
kernel: check
	@$(MAKE) $(MAKE_JOBS) -C $(LINUX_PATH) uImage V=0 CROSS_COMPILE=$(CROSS_COMPILE)

clean:
	@$(MAKE) -C $(XBOOT_PATH) $@
	@$(MAKE) -C $(UBOOT_PATH) $@
	@$(MAKE) -C $(LINUX_PATH) $@
	@$(RM) -rf $(OUT_PATH)

distclean: clean
	@$(MAKE) -C $(XBOOT_PATH) $@
	@$(MAKE) -C $(UBOOT_PATH) $@
	@$(MAKE) -C $(LINUX_PATH) $@
	@$(RM) -f $(CONFIG_ROOT)
	@$(RM) -rf $(OUT_PATH)

config: init
	@$(MAKE) -C $(XBOOT_PATH) $(shell cat $(CONFIG_ROOT) | grep 'XBOOT_CONFIG=' | sed 's/XBOOT_CONFIG=//g')
	@$(MAKE) -C $(UBOOT_PATH) $(shell cat $(CONFIG_ROOT) | grep 'UBOOT_CONFIG=' | sed 's/UBOOT_CONFIG=//g')
	@$(MAKE) -C $(LINUX_PATH) $(shell cat $(CONFIG_ROOT) | grep 'KERNEL_CONFIG=' | sed 's/KERNEL_CONFIG=//g')
	@$(MAKE) rootfs
	@$(MKDIR) -p $(OUT_PATH)
	@$(CP) -f $(BUILD_PATH)/$(ISP_SHELL) $(OUT_PATH)
	@$(CP) -f $(BUILD_PATH)/$(PART_SHELL) $(OUT_PATH)
	@$(CP) -f $(IPACK_PATH)/bin/$(DOWN_TOOL) $(OUT_PATH)
	@$(ECHO) $(COLOR_YELLOW)"platform info :"$(COLOR_ORIGIN)
	@$(MAKE) info

dtb: check
	@$(MAKE) -C $(LINUX_PATH) $(LINUX_DTB) CROSS_COMPILE=$(CROSS_COMPILE)
	@ln -fs arch/arm/boot/dts/$(LINUX_DTB) $(LINUX_PATH)/dtb

spirom: check
	@$(MAKE) -C $(IPACK_PATH) all ZEBU_RUN=$(ZEBU_RUN)
	@if [ -f $(IPACK_PATH)/bin/$(SPI_BIN) ]; then \
		$(ECHO) $(COLOR_YELLOW)"Copy "$(SPI_BIN)" to out folder."$(COLOR_ORIGIN); \
		$(CP) -f $(IPACK_PATH)/bin/$(SPI_BIN) $(OUT_PATH); \
	fi

tool_isp:
	@$(MAKE) -C $(TOPDIR)/build/tools/isp

isp: check tool_isp
	@if [ -f $(XBOOT_PATH)/bin/$(XBOOT_BIN) ]; then \
		$(CP) -f $(XBOOT_PATH)/bin/$(XBOOT_BIN) $(OUT_PATH); \
		$(ECHO) $(COLOR_YELLOW)"Copy "$(XBOOT_BIN)" to out folder."$(COLOR_ORIGIN); \
	else \
		$(ECHO) $(COLOR_YELLOW)$(XBOOT_BIN)" is not exist."$(COLOR_ORIGIN); \
		exit 1; \
	fi
	@if [ -f $(UBOOT_PATH)/$(UBOOT_BIN) ]; then \
		$(CP) -f $(UBOOT_PATH)/u-boot.img $(OUT_PATH); \
		$(ECHO) $(COLOR_YELLOW)"Copy "$(UBOOT_BIN)" to out folder."$(COLOR_ORIGIN); \
	else \
		$(ECHO) $(COLOR_YELLOW)"u-boot.img is not exist."$(COLOR_ORIGIN); \
		exit 1; \
	fi
	@if [ -f $(LINUX_PATH)/$(VMLINUX) ]; then \
		if [ "$(USE_QK_BOOT)" = "1" ];then \
			$(CP) -f $(LINUX_PATH)/$(VMLINUX) $(OUT_PATH); \
			$(ECHO) $(COLOR_YELLOW)"Copy "$(VMLINUX)" to out folder."$(COLOR_ORIGIN); \
			$(CROSS_COMPILE)objcopy -O binary -S $(OUT_PATH)/$(VMLINUX) $(OUT_PATH)/$(VMLINUX).bin; \
			cd $(IPACK_PATH); \
			./add_uhdr.sh linux-`date +%Y%m%d-%H%M%S` $(PWD)/$(OUT_PATH)/$(VMLINUX).bin \
			$(PWD)/$(OUT_PATH)/$(KERNEL_BIN) 0x308000 0x308000; \
			cd $(PWD); \
			if [ -f $(OUT_PATH)/$(KERNEL_BIN) ]; then \
				$(ECHO) $(COLOR_YELLOW)"Add uhdr in "$(KERNEL_BIN)"."$(COLOR_ORIGIN); \
			else \
				$(ECHO) $(COLOR_YELLOW)"Gen "$(KERNEL_BIN)" fail."$(COLOR_ORIGIN); \
			fi; \
		else \
			$(CP) -vf $(LINUX_PATH)/arch/arm/boot/$(KERNEL_BIN) $(OUT_PATH); \
		fi ; \
	else \
		$(ECHO) $(COLOR_YELLOW)$(VMLINUX)" is not exist."$(COLOR_ORIGIN); \
		exit 1; \
	fi
	@if [ -f $(LINUX_PATH)/$(DTB) ]; then \
		if [ "$(USE_QK_BOOT)" = "1" ];then \
			$(CP) -f $(LINUX_PATH)/$(DTB) $(OUT_PATH)/$(DTB).raw ; \
			cd $(IPACK_PATH); \
			pwd && pwd && pwd; \
			./add_uhdr.sh dtb-`date +%Y%m%d-%H%M%S` ../$(OUT_PATH)/$(DTB).raw ../$(OUT_PATH)/$(DTB) 0x000000 0x000000; \
			cd .. ; \
		else \
			$(CP) -vf $(LINUX_PATH)/$(DTB) $(OUT_PATH)/$(DTB) ; \
		fi ; \
		$(ECHO) $(COLOR_YELLOW)"Copy "$(DTB)" to out folder."$(COLOR_ORIGIN); \
	else \
		$(ECHO) $(COLOR_YELLOW)$(DTB)" is not exist."$(COLOR_ORIGIN); \
		exit 1; \
	fi
	@cd out/; ./$(ISP_SHELL)

part:
	@cd out; ./$(PART_SHELL)

rom: check
	@if [ "$(NEED_ISP)" = '1' ]; then  \
		$(MAKE) isp; \
	else \
		$(MAKE) spirom; \
	fi

all: check
	@$(MAKE) xboot
	@$(MAKE) uboot
	@$(MAKE) kernel
	@$(MAKE) dtb
	@$(MAKE) rom

init:
	@$(RM) -f $(CONFIG_ROOT)
	@./build/config.sh $(CROSS_V5_COMPILE) $(CROSS_V7_COMPILE)

check:
	@if ! [ -f $(CONFIG_ROOT) ]; then \
		$(ECHO) $(COLOR_YELLOW)"Please \"make config\" first."$(COLOR_ORIGIN); \
		exit 1; \
	fi

rootfs:
	@cd ./linux/rootfs/initramfs/; ls; ./build_disk.sh; cd $(TOPDIR);

info:
	@$(ECHO) "XBOOT =" $(XBOOT_CONFIG)
	@$(ECHO) "UBOOT =" $(UBOOT_CONFIG)
	@$(ECHO) "KERNEL =" $(KERNEL_CONFIG)
	@$(ECHO) "CROSS COMPILER =" $(CROSS_COMPILE)
	@$(ECHO) "NEED ISP =" $(NEED_ISP)
	@$(ECHO) "ZEBU RUN =" $(ZEBU_RUN)
