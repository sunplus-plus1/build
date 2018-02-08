armv5-eabi--glibc--stable-2017.05-toolchains-1-1


Toolchains are hosted here: http://toolchains.free-electrons.com/

All the licenses can be found here: http://toolchains.free-electrons.com/downloads/releases/licenses/
All the sources can be found here: http://toolchains.free-electrons.com/downloads/releases/sources/


PACKAGE      VERSION  LICENSE
buildroot    2017.05  GPL-2.0+
gcc-final    5.4.0    unknown
gawk         4.1.4    GPL-3.0+
gcc-initial  5.4.0    unknown
binutils     2.27     GPL-3.0+, libiberty LGPL-2.1+
gmp          6.1.2    LGPL-3.0+ or GPL-2.0+
m4           1.4.18   GPL-3.0+
mpc          1.0.3    LGPL-3.0+
mpfr         3.1.5    LGPL-3.0+
autoconf     2.69     GPL-3.0+ with exceptions
libtool      2.4.6    GPL-2.0+
automake     1.15     GPL-2.0+
gdb          7.11.1   GPL-2.0+, LGPL-2.0+, GPL-3.0+, LGPL-3.0+
expat        2.2.0    MIT
pkgconf      0.9.12   pkgconf license
ncurses      6.0      MIT with advertising clause
glibc          2.24      GPL-2.0+ (programs), LGPL-2.1+, BSD-3-Clause, MIT (library)
linux-headers  3.10.105  GPL-2.0
dash           0.5.8     BSD-3-Clause, GPL-2.0+ (mksignames.c)
gdb            7.11.1    GPL-2.0+, LGPL-2.0+, GPL-3.0+, LGPL-3.0+

For those who would like to reproduce the toolchain, you can just follow these steps:

    git clone https://github.com/free-electrons/buildroot-toolchains.git buildroot
    cd buildroot
    git checkout 2017.05-toolchains-1

    curl http://toolchains.free-electrons.com/downloads/releases/build_fragments/armv5-eabi--glibc--stable-2017.05-toolchains-1-1.defconfig > .config
    make olddefconfig
    make

This toolchain has been built, and the test system built with it has
successfully booted.
This doesn't mean that this toolchain will work in every cases, but it is at
least capable of building a Linux kernel with a basic rootfs that boots.
FLAG: TEST-OK
