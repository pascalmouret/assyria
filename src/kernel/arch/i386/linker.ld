ENTRY(boot)
OUTPUT_FORMAT(elf32-i386)

SECTIONS {
	. = 0x100000;

	.init BLOCK (0x1000) : ALIGN (0x1000) {
		*(.multiboot)
		*(.init)
	}

   	/* 	The kernel will live at 3GB + 1MB in the virtual
		address space, which will be mapped to 1MB in the
		physical address space. */
	. = 0xC0101000;
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