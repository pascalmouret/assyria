import gdt # import to make 'setGDT' global
import interrupt.idt # import to make 'setIDT' global
import interrupt.init
import vga
import paging.paging
import multiboot
import mem


proc archInit*(): void =
  interruptInit()
  vgaInit()
  pagingInit()