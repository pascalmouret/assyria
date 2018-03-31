AS=./cross/bin/i586-elf-as
GCC=./cross/bin/i586-elf-gcc
NIM=nim

CFLAGS=-w -nostdlib -ffreestanding -O2 -Wall -Wextra
LDFLAGS=-ffreestanding -O2 -nostdlib

NIMFLAGS=\
--passc:"$(CFLAGS)" \
--noLinking \
--gc:none \
--noMain \
--deadCodeElim:on \
--boundChecks:on \
--cpu:i386 \
--os:standalone \
--cc:gcc \

kernel:
	$(AS) src/kernel/asm/boot.s -o target/boot.o
	$(NIM) c -d:release --gcc.exe:"$(GCC)" $(NIMFLAGS) ./src/kernel/nim/kernel.nim
	$(GCC) -T src/kernel/linker.ld $(CFLAGS) -o nimOS.bin target/boot.o src/kernel/nim/nimcache/kernel.o src/kernel/nim/nimcache/stdlib_system.o

install:
	rm -rf ./target
	mkdir ./target
	make kernel
