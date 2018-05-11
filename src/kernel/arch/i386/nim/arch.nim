import gdt # import to make 'setGDT' global
import idt # import to make 'setIDT' global
import vga
import interrupt.init
import paging.allocator
import multiboot

proc archInit*(mbInfo: MultibootInfoPtr): void =
  interruptInit()
  vgaInit()
  initPageStack(mbInfo.mmapPtr[], mbInfo.mmapLength)
