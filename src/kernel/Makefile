include ../../make.config

ARCH_DIR=arch/$(ARCH_TARGET)

NIMCACHE:=$(NIMCACHE)/kernel
NIMFLAGS+=\
--path:$(ARCH_DIR)/nim \
--path:nim \
--nimcache:$(NIMCACHE) \
--deadCodeElim:on \
--noLinking \
--gc:none \
--noMain \
--boundChecks:on \
--import:libc

CFLAGS+=-Iinclude -lgcc

.PHONY: install install-lib

$(KERNEL_BIN): boot.o install-lib
	$(NIM) c -d:release $(NIMFLAGS) nim/kernel.nim
	$(GCC) -T $(ARCH_DIR)/linker.ld -o $@ `find $(NIMCACHE) -name *.o` $(BUILD_DIR)/boot.o $(CFLAGS)

boot.o:
	mkdir -p $(BUILD_DIR)
	$(AS) $(ARCH_DIR)/boot.s -o $(BUILD_DIR)/$@

install: $(KERNEL_BIN)

install-lib:
