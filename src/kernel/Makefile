CFLAGS=-nostdlib -ffreestanding -O2 -Wall -Wextra -isystem $(SYSROOT)/usr/include

NIMCACHE=$(BUILD_DIR)/kernel/nimcache

NIMFLAGS=\
--passc:"$(CFLAGS)" \
--noLinking \
--gc:none \
--noMain \
--deadCodeElim:on \
--boundChecks:on \
--cpu:$(TARGET) \
--os:standalone \
--cc:gcc \
--path:$(SYSROOT) \
--gcc.exe:$(GCC) \
--nimcache:$(NIMCACHE)

.PHONY: kernel install-lib install-headers install

kernel:
	$(AS) $(TARGET)/boot.s -o $(BUILD_DIR)/boot.o
	$(NIM) c -d:release $(NIMFLAGS) kernel.nim
	$(GCC) -T $(TARGET)/linker.ld $(CFLAGS) -o $(BUILD_DIR)/nimOS.bin $(BUILD_DIR)/boot.o `find $(NIMCACHE) -name *.o`

install-lib: install-headers
	mkdir -p $(SYSROOT)
	cp -R $(TARGET)/nim/ $(SYSROOT)

install-headers:
	mkdir -p $(SYSROOT)/usr/include
	cp -R include/ $(SYSROOT)/usr/include

install: kernel
