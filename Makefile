.PHONY: all clean run dump

DIR_BUILD=build
DIR_SRC=src

FC=gfortran
# $ gfortran -v
# Using built-in specs.
# COLLECT_GCC=gfortran
# COLLECT_LTO_WRAPPER=/usr/lib/gcc/x86_64-pc-linux-gnu/13.1.1/lto-wrapper
# Target: x86_64-pc-linux-gnu
# Configured with: /build/gcc/src/gcc/configure --enable-languages=ada,c,c++,d,fortran,go,lto,objc,obj-c++ --enable-bootstrap --prefix=/usr --libdir=/usr/lib --libexecdir=/usr/lib --mandir=/usr/share/man --infodir=/usr/share/info --with-bugurl=https://bugs.archlinux.org/ --with-build-config=bootstrap-lto --with-linker-hash-style=gnu --with-system-zlib --enable-__cxa_atexit --enable-cet=auto --enable-checking=release --enable-clocale=gnu --enable-default-pie --enable-default-ssp --enable-gnu-indirect-function --enable-gnu-unique-object --enable-libstdcxx-backtrace --enable-link-serialization=1 --enable-linker-build-id --enable-lto --enable-multilib --enable-plugin --enable-shared --enable-threads=posix --disable-libssp --disable-libstdcxx-pch --disable-werror
# Thread model: posix
# Supported LTO compression algorithms: zlib zstd
# gcc version 13.1.1 20230714 (GCC) 

F2PY=python -m numpy.f2py
# $ python -m numpy.f2py -v
# 1.24.2

CFLAGS=-Wall -Wno-tabs -Wextra -Wunused -Wsurprising -Wpedantic -Wuse-without-only -Waliasing -Winteger-division -Wcharacter-truncation -Wimplicit-interface -Wimplicit-procedure -Wconversion -Wconversion-extra -Wrealloc-lhs-all -Wno-maybe-uninitialized -fimplicit-none
# release
CFLAGS+= -O3 -march=native
# debug
# CFLAGS+=' -fcheck=all -fbacktrace -g'

all: clean fortran pymodule dump readme

pymodule: clean
	${F2PY} --f90flags='${CFLAGS}' -c src/types.f90 src/arrayops.f90 src/integrate.f90 -m mymodule

fortran: clean
	mkdir -p ${DIR_BUILD}
	${FC} ${CFLAGS} -J${DIR_BUILD} -c ${DIR_SRC}/types.f90 -o ${DIR_BUILD}/types.o
	${FC} ${CFLAGS} -J${DIR_BUILD} -c ${DIR_SRC}/arrayops.f90 -o ${DIR_BUILD}/arrayops.o
	${FC} ${CFLAGS} -J${DIR_BUILD} -c ${DIR_SRC}/integrate.f90 -o ${DIR_BUILD}/integrate.o

	${FC} ${CFLAGS} -J${DIR_BUILD} -c ${DIR_SRC}/main.f90 -o ${DIR_BUILD}/main.o
	${FC} ${CFLAGS} -J${DIR_BUILD} ${DIR_BUILD}/types.o ${DIR_BUILD}/integrate.o ${DIR_BUILD}/arrayops.o ${DIR_BUILD}/main.o -o main
	${FC} ${CFLAGS} -J${DIR_BUILD} -c ${DIR_SRC}/debug.f90 -o ${DIR_BUILD}/debug.o
	${FC} ${CFLAGS} -J${DIR_BUILD} ${DIR_BUILD}/types.o ${DIR_BUILD}/integrate.o ${DIR_BUILD}/arrayops.o ${DIR_BUILD}/debug.o -o debug

debug: fortran pymodule
	./debug
	python debug.py debug.out

run: fortran
	./main

clean:
	rm -f *.o *.mod *.so
	rm -rf build


dump: fortran pymodule
	objdump -Mintel --disassemble='__integrate_MOD_trapz' --visualize-jumps 'mymodule.cpython-311-x86_64-linux-gnu.so' > objdump_pymodule_trapz.dump
	objdump -Mintel --disassemble='__integrate_MOD_trapz' --visualize-jumps 'build/integrate.o' > objdump_fortran_trapz.dump
	rm mymodule.pyf && python -m numpy.f2py src/types.f90 src/arrayops.f90 src/integrate.f90 -m mymodule -h mymodule.pyf
	./main > main.out
	python demo.py > demo.out


# $ gpp --version
# GPP 2.27
# Copyright (C) 1996-2001 Denis Auroux
# Copyright (C) 2003-2020 Tristan Miller
# This is free software; see the source for copying conditions.  There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

readme: dump
	gpp -o README.md -T README.template.md