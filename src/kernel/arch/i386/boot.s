.global boot

/* Declare constants for the multiboot header. */
.set ALIGN,    1<<0             /* align loaded modules on page boundaries */
.set MEMINFO,  1<<1             /* provide memory map */
.set FLAGS,    ALIGN | MEMINFO  /* this is the Multiboot 'flag' field */
.set MAGIC,    0x1BADB002       /* 'magic number' lets bootloader find the header */
.set CHECKSUM, -(MAGIC + FLAGS) /* checksum of above, to prove we are multiboot */

.set KERNEL_BASE, 0xC0000000 # kernel memory will start at 3GB

/*
Declare a multiboot header that marks the program as a kernel. These are magic
values that are documented in the multiboot standard. The bootloader will
search for this signature in the first 8 KiB of the kernel file, aligned at a
32-bit boundary. The signature is in its own section so the header can be
forced to be within the first 8 KiB of the kernel file.
*/
.section .multiboot
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM

/* kernel stack */
.section .bss
.align 16
stack_bottom:
.skip 16384 # 16 KiB
stack_top:

.section .data
.align 0x1000 # page directory needs to be 4k aligned
.set KERNEL_PAGE_INDEX, (KERNEL_BASE >> 22) - 1
.set LAST_PAGE_DIR_ENTRY_OFFSET, 1023 * 4
page_directory:
	/*
	Set two simple page directoy entries. They both refer to the first 4MB of memory.
	As such the frame address is 0 and no page directory needed.
	The first page is needed because there is no paging set initially, so CPU would not
	be able to find the entry point.
	The second page is where the kernel is actually located at KERNEL_BASE.
	The bits being set are:
	bit 0: entry is present
	bit 1: the page is read/write
	bit 7: the page is 4MB
	*/
	.long 0x00000083
	/* skippinig empty entries */
	.rept KERNEL_PAGE_INDEX
		.long 0
	.endr
	.long 0x00000083
	/* skippinig empty entries */
	.rept 1024 - KERNEL_PAGE_INDEX
		.long 0
	.endr
/*
GDT and IDT are already setup here because it leads to less assembly code and
their sizes probably won't change anytime soon.
*/
.set GDT_SIZE, 4 * 8
gdt:
	.skip GDT_SIZE
gdtr:
	.short GDT_SIZE - 1
	.long gdt

.set INTERRUPT_TABLE_SIZE, 256 * 8
idt:
	.skip INTERRUPT_TABLE_SIZE
idtr:
	.short INTERRUPT_TABLE_SIZE
	.long idt

.section .init
.align 4
boot:
	/* put address of page directory into cr3 */
	mov $(page_directory - KERNEL_BASE), %ecx
	mov %ecx, %cr3
	
	/* enable PSE */
	mov %cr4, %ecx
	or $(1 << 4), %ecx
	mov %ecx, %cr4
	
	/* enable paging */
	mov %cr0, %ecx
	or $(1 << 31), %ecx
	mov %ecx, %cr0

	/* long jump into high memory */
	lea init_kernel, %ecx
	jmp %ecx
.section .text
.align 4
setupIDT:
	/* setting and loading the IDT */
	pushl $idt
	call setIDT
	add $4, %esp
	lidt (idtr)
	/*
	For convinience the last page directory entry will map
	to itself, resulting in the address 0xFFFFF000 always pointing
	to the page directory.

	Since pages are addressed by physical addresses we need
	to subtract the KERNEL_BASE.
	*/
	movl $(page_directory - KERNEL_BASE), %ecx
	/* shifting right to get frame address */
	shrl $12, %ecx
	/* shifting left to put into position for directory entry */
	shll $12, %ecx
	/* add flags (present and read/write) */
	orl $0x3, %ecx
	movl $page_directory, %ebx
	movl %ecx, LAST_PAGE_DIR_ENTRY_OFFSET(%ebx)
	ret
setupGDT:
	pushl $gdt
	call setGDT
	add $4, %esp
	call loadGDT
	ret
loadGDT:
	/*
	Simply loading the GDT will have no effect, registers
	also need to address the correct segment.
	The code segement can only be set during a long jump,
	which is why we need to jump to the next instruction
	instead proceeding normally.
	The data segments used are 0x8 and 0x10, which are
	assumed to be code and data respectively.
	*/
	lgdt (gdtr)
	jmp $0x08, $flushGDT
flushGDT:
	/*
	Point all data segments to new segment.
	*/
	mov $0x10, %ax
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %fs
	mov %ax, %gs
	mov %ax, %ss
	ret
init_kernel:
	/* invalidate identity mapped page */
	movl $page_directory, 0
	invlpg 0

	/* init stack */
	movl $stack_top, %esp

	/* mb args */
	push %eax
	push %ebx

	call setupGDT
	call setupIDT

	/* call into nim */
	call kernel_main

	cli
end:	
	hlt
	jmp end
	