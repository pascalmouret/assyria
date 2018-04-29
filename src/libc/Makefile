include ../../make.config

NIMCACHE:=$(NIMCACHE)/libc

NIMFLAGS+=\
--nimcache=$(NIMCACHE)\
--gc:none \
--noMain \
--boundChecks:on \
--noLinking \
--deadCodeElim:on \
--path:../kernel/arch/$(ARCH_TARGET)/nim \
--app:lib

NIM_FILES=nim/libc.nim
OBJECTS=$(patsubst nim/%.nim, $(SYSROOT)/usr/lib/%.a, $(NIM_FILES))

.PHONY: install-lib install-headers install

install:

install-lib: install-headers $(OBJECTS)
	mkdir -p $(NIMPATH)
	cp -R nim/ $(NIMPATH)

install-headers:
	mkdir -p $(SYSROOT)/usr/include
	cp -R include/ $(SYSROOT)/usr/include

$(SYSROOT)/usr/lib/%.a: $(NIMCACHE)/%.o
	mkdir -p $(SYSROOT)/usr/lib
	$(AR) rcs $@ $<

$(NIMCACHE)/%.o: nim/%.nim
	$(NIM) compileToC -d:release $(NIMFLAGS) --out:$@ $<
