import gdt # import to make 'setGDT' available
import idt # import to make 'setIDT' available
import vga
import interrupt.init

proc archInit*(): void =
  interruptInit()
  clear()
