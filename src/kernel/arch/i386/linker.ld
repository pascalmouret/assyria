ENTRY(boot)
OUTPUT_FORMAT(elf32-i386)

SECTIONS {
	/*
	We skip lower memory entirely to avoid overwritting
	important stuff.
	*/
	. = 0x100000;

	/*
	Multiboot and the initial loader need to have
	their real addresses because paging will not be
	enabled yet.
	*/
	.init : ALIGN (0x1000) {
		*(.multiboot)
		*(.init)
	}

   	/*
	The kernel will live at 3GB + 1MB in the virtual
	address space, which will be mapped to 1MB in the
	physical address space.
	We do this by setting the location but then offsetting
	the physical memory locations backwards so they
	end up at the beginning of the binary but with
	addresses at the end of memory.
	We also need to offset the location so it does not
	overlap with the init section in real memory.
	*/
	. = 0xC0100000 + SIZEOF (.init);
   	ldKernelStartSymbol = .;

   	.text : AT(ADDR(.text) - 0xC0000000) {
       	*(.text)
       	*(.rodata*)
   	}

   	.data ALIGN (0x1000) : AT(ADDR(.data) - 0xC0000000) {
		*(.data)
   	}

   	.bss : AT(ADDR(.bss) - 0xC0000000) {
		_sbss = .;
       	*(COMMON)
       	*(.bss)
       	_ebss = .;
   	}

   	ldKernelEndSymbol = .;
}