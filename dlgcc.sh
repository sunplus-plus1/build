#!/bin/bash
set -x
GCC_ARM_NONE=gcc-arm-9.2-2019.12-x86_64-arm-none-eabi
GCC_AARCH64_NONE=gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu
cd crossgcc/ 

if [ ! -d ${GCC_ARM_NONE} ]; then
    if [ -f ${GCC_ARM_NONE}.tar.xz ]; then
        rm ${GCC_ARM_NONE}.tar.xz
    fi
    wget https://developer.arm.com/-/media/Files/downloads/gnu-a/9.2-2019.12/binrel/${GCC_ARM_NONE}.tar.xz
    tar Jxvf ${GCC_ARM_NONE}.tar.xz
    if [ $? -eq 0 ]; then
        rm ${GCC_ARM_NONE}.tar.xz
    else
        exit 1
    fi
fi

if [ ! -d ${GCC_AARCH64_NONE} ]; then
    if [ -f ${GCC_AARCH64_NONE}.tar.xz ]; then
        rm ${GCC_AARCH64_NONE}.tar.xz
    fi
    wget https://developer.arm.com/-/media/Files/downloads/gnu-a/9.2-2019.12/binrel/${GCC_AARCH64_NONE}.tar.xz 
    tar Jxvf ${GCC_AARCH64_NONE}.tar.xz
    if [ $? -eq 0 ]; then
        rm ${GCC_AARCH64_NONE}.tar.xz
    else
        exit 1
    fi
fi