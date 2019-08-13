TARGET=arm-none-eabi
BASEDIR=$(shell pwd)
PREFIX=$(BASEDIR)/$(TARGET)
MAKEOPTS="-j16"
PATH:=$(PREFIX)/bin:$(PATH)

BINUTILS_VER=2.32
BINUTILS_TAR=binutils-$(BINUTILS_VER).tar.xz
BINUTILS_URL=ftp://ftp.gnu.org/gnu/binutils/$(BINUTILS_TAR)

GMP_VER=6.1.2
GMP_TAR=gmp-$(GMP_VER).tar.xz
GMP_URL=ftp://ftp.gnu.org/gnu/gmp/$(GMP_TAR)

MPFR_VER=4.0.2
MPFR_TAR=mpfr-$(MPFR_VER).tar.xz
MPFR_URL=ftp://ftp.gnu.org/gnu/mpfr/$(MPFR_TAR)

MPC_VER=1.1.0
MPC_TAR=mpc-$(MPC_VER).tar.gz
MPC_URL=http://ftp.gnu.org/gnu/mpc/$(MPC_TAR)

ISL_VER=0.21
ISL_TAR=isl-$(ISL_VER).tar.xz
ISL_URL=http://isl.gforge.inria.fr/$(ISL_TAR)

CLOOG_VER=0.18.4
CLOOG_TAR=cloog-$(CLOOG_VER).tar.gz
CLOOG_URL=http://www.bastoul.net/cloog/pages/download/$(CLOOG_TAR)

GCC_VER=9.2.0
GCC_TAR=gcc-$(GCC_VER).tar.xz
GCC_URL=ftp://ftp.gnu.org/gnu/gcc/gcc-$(GCC_VER)/$(GCC_TAR)

GDB_VER=8.3
GDB_TAR=gdb-$(GDB_VER).tar.xz
GDB_URL=ftp://ftp.gnu.org/gnu/gdb/$(GDB_TAR)

NEWLIB_VER=3.1.0
NEWLIB_TAR=newlib-$(NEWLIB_VER).tar.gz
NEWLIB_URL=ftp://sourceware.org/pub/newlib/$(NEWLIB_TAR)

all: gcc gdb

src/$(BINUTILS_TAR):
	wget -P src $(BINUTILS_URL)

src/$(GMP_TAR):
	wget -P src $(GMP_URL)

src/$(MPFR_TAR):
	wget -P src $(MPFR_URL)

src/$(MPC_TAR):
	wget -P src $(MPC_URL)

src/$(ISL_TAR):
	wget -P src $(ISL_URL)

src/$(CLOOG_TAR):
	wget -P src $(CLOOG_URL)

src/$(GCC_TAR):
	wget -P src $(GCC_URL)

src/$(GDB_TAR):
	wget -P src $(GDB_URL)

src/$(NEWLIB_TAR):
	wget -P src $(NEWLIB_URL)

src/binutils-$(BINUTILS_VER): src/$(BINUTILS_TAR)
	tar -C src -xf $<

src/gmp-$(GMP_VER): src/$(GMP_TAR)
	tar -C src -xf $<

src/mpfr-$(MPFR_VER): src/$(MPFR_TAR)
	tar -C src -xf $<

src/mpc-$(MPC_VER): src/$(MPC_TAR)
	tar -C src -xf $<

src/isl-$(ISL_VER): src/$(ISL_TAR)
	tar -C src -xf $<

src/cloog-$(CLOOG_VER): src/$(CLOOG_TAR)
	tar -C src -xf $<

src/gcc-$(GCC_VER): src/$(GCC_TAR)
	tar -C src -xf $<

src/gdb-$(GDB_VER): src/$(GDB_TAR)
	tar -C src -xf $<

src/newlib-$(NEWLIB_VER): src/$(NEWLIB_TAR)
	tar -C src -xf $<

binutils: src/binutils-$(BINUTILS_VER)
	mkdir -p build/binutils
	cd build/binutils; \
	$(BASEDIR)/$</configure --target=$(TARGET) --prefix=$(PREFIX) --enable-interwork --enable-multilib --disable-nls --disable-libssp --disable-shared --disable-gdb; \
	$(MAKE) $(MAKEOPTS); \
	mkdir -p $(PREFIX); \
	$(MAKE) install

gmp: src/gmp-$(GMP_VER)
	mkdir -p build/gmp
	cd build/gmp; \
	$(BASEDIR)/$</configure --prefix=$(PREFIX) --disable-shared; \
	$(MAKE) $(MAKEOPTS); \
	$(MAKE) install-strip

mpfr: src/mpfr-$(MPFR_VER)
	mkdir -p build/mpfr
	cd build/mpfr; \
	$(BASEDIR)/$</configure --prefix=$(PREFIX) --with-gmp=$(PREFIX) --disable-shared; \
	$(MAKE) $(MAKEOPTS); \
	$(MAKE) install-strip

mpc: src/mpc-$(MPC_VER)
	mkdir -p build/mpc
	cd build/mpc; \
	$(BASEDIR)/$</configure --prefix=$(PREFIX) --with-gmp=$(PREFIX) --with-mpfr=$(PREFIX) --disable-shared; \
	$(MAKE) $(MAKEOPTS); \
	$(MAKE) install-strip

isl: src/isl-$(ISL_VER)
	mkdir -p build/isl
	cd build/isl; \
	$(BASEDIR)/$</configure --prefix=$(PREFIX) --with-gmp=$(PREFIX) --disable-shared; \
	$(MAKE) $(MAKEOPTS); \
	$(MAKE) install-strip

cloog: src/cloog-$(CLOOG_VER)
	mkdir -p build/cloog
	cd build/cloog; \
	$(BASEDIR)/$</configure --prefix=$(PREFIX) --with-gmp=$(PREFIX) --with-isl=$(PREFIX) --disable-shared; \
	$(MAKE) $(MAKEOPTS); \
	$(MAKE) install-strip

gcc1: src/gcc-$(GCC_VER) binutils gmp mpfr mpc isl cloog
	mkdir -p build/gcc
	cd build/gcc; \
	$(BASEDIR)/$</configure --target=$(TARGET) --prefix=$(PREFIX) --disable-nls --disable-shared --disable-threads --enable-languages=c,c++ --enable-interwork --with-multilib-list=rmprofile --with-newlib --with-headers=../../newlib-$(NEWLIB_VER)/newlib/libc/include --disable-libssp --disable-libstdcxx-pch --with-gmp=$(PREFIX) --with-mpfr=$(PREFIX) --with-mpc=$(PREFIX) --with-isl=$(PREFIX) --with-cloog=$(PREFIX) --disable-decimal-float --disable-libgomp --disable-libmudflap --disable-libffi --disable-libquadmath --disable-tls; \
	$(MAKE) $(MAKEOPTS) all-gcc; \
	$(MAKE) install-strip-gcc

newlib: src/newlib-$(NEWLIB_VER)
	mkdir -p build/newlib
	cd build/newlib; \
	$(BASEDIR)/$</configure --target=$(TARGET) --prefix=$(PREFIX) --enable-interwork --enable-multilib --disable-libssp --disable-nls --disable-decimal-float --enable-newlib-io-c99-formats --enable-newlib-io-long-long --disable-newlib-supplied-syscalls --enable-newlib-reent-small --disable-newlib-atexit-dynamic-alloc --disable-newlib-fvwrite-in-streamio --disable-newlib-fseek-optimization --disable-newlib-wide-orient --disable-newlib-unbuf-stream-opt --enable-newlib-global-atexit --enable-newlib-nano-formatted-io --enable-lite-exit --enable-newlib-nano-malloc --disable-newlib-fvwrite-in-streamio; \
	$(MAKE) $(MAKEOPTS); \
	$(MAKE) install

gcc: gcc1 newlib
	cd build/gcc; \
	$(MAKE) $(MAKEOPTS); \
	$(MAKE) install-strip

gdb: src/gdb-$(GDB_VER)
	mkdir -p build/gdb
	cd build/gdb; \
	$(BASEDIR)/$</configure --target=$(TARGET) --prefix=$(PREFIX) --enable-interwork --enable-multilib --disable-libssp --disable-nls --with-system-readline --enable-sim-arm --enable-sim-stdio --with-guile=no; \
	$(MAKE) $(MAKEOPTS); \
	$(MAKE) install; \
	strip $(PREFIX)/bin/arm-none-eabi-gdb; \
	strip $(PREFIX)/bin/arm-none-eabi-run

clean:
	rm -rf build $(PREFIX)
	cd src ; rm -rf `ls -1 | grep -v 'gz\|bz2\|xz\|Makefile' | xargs`

distclean: clean
	rm -rf src

