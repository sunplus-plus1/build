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

CONFIG_ROOT = ./.config

LINUX_DTB = $(shell echo $(KERNEL_CONFIG) | sed 's/_defconfig//g' | sed 's/_/-/g').dtb

XBOOT_PATH = ./boot/xboot
UBOOT_PATH = ./boot/uboot
LINUX_PATH = ./linux/kernel
IPACK_PATH = ./ipack

#Build STAGE 1->2
STAGE1_TARGETS += xboot
STAGE1_TARGETS += uboot
STAGE1_TARGETS += kernel
STAGE1_TARGETS += dtb
STAGE2_TARGETS += rom

.PHONY: all xboot uboot kenel rom clean distclean config init check rootfs info
.PHONY: dtb

#xboot build
xboot: check
	@$(MAKE) -j -C $(XBOOT_PATH) all 

#uboot build
uboot: check
	@$(MAKE) -j -C $(UBOOT_PATH) all CROSS_COMPILE=$(CROSS_COMPILE)

#kernel build
kernel: check
	@$(MAKE) -j -C $(LINUX_PATH) uImage V=0 CROSS_COMPILE=$(CROSS_COMPILE)

clean: 
	@$(MAKE) -C $(XBOOT_PATH) $@
	@$(MAKE) -C $(UBOOT_PATH) $@
	@$(MAKE) -C $(LINUX_PATH) $@

distclean: clean
	@$(MAKE) -C $(XBOOT_PATH) $@
	@$(MAKE) -C $(UBOOT_PATH) $@
	@$(MAKE) -C $(LINUX_PATH) $@
	@rm -f $(CONFIG_ROOT)

config: init
	@$(MAKE) -C $(XBOOT_PATH) $(shell cat $(CONFIG_ROOT) | grep 'XBOOT_CONFIG=' | sed 's/XBOOT_CONFIG=//g')
	@$(MAKE) -C $(UBOOT_PATH) $(shell cat $(CONFIG_ROOT) | grep 'UBOOT_CONFIG=' | sed 's/UBOOT_CONFIG=//g')
	@$(MAKE) -C $(LINUX_PATH) $(shell cat $(CONFIG_ROOT) | grep 'KERNEL_CONFIG=' | sed 's/KERNEL_CONFIG=//g')
	@$(MAKE) rootfs

dtb: check
	@$(MAKE) -C $(LINUX_PATH) $(LINUX_DTB) CROSS_COMPILE=$(CROSS_COMPILE)
	@ln -fs arch/arm/boot/dts/$(LINUX_DTB) $(LINUX_PATH)/dtb

rom: check
	@$(MAKE) -C $(IPACK_PATH) all

all: check
	@$(MAKE) $(STAGE1_TARGETS)
	@$(MAKE) $(STAGE2_TARGETS)

init:
	@rm -f $(CONFIG_ROOT)
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


