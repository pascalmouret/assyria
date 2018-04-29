include make.config

ISO_DIR = $(BUILD_DIR)/isodir
ISO = $(BUILD_DIR)/assyria.iso

.PHONY: all iso clean install-lib install

all: iso

iso: clean install $(ISO)

install: install-lib
	for PROJECT in $(PROJECTS); do \
		(cd src/$$PROJECT && $(MAKE) install) \
	done

install-lib:
	for PROJECT in $(PROJECTS); do \
  	(cd src/$$PROJECT && $(MAKE) install-lib) \
	done

clean:
	rm -rf $(BUILD_DIR)

$(ISO): install
	mkdir -p $(ISO_DIR)/boot/grub
	cp $(KERNEL_BIN) $(ISO_DIR)/boot/
	cp build/grub.cfg $(ISO_DIR)/boot/grub/grub.cfg
	grub-mkrescue -o $(ISO) $(ISO_DIR)
