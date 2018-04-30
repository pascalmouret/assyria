import gdt # import to make 'setGDT' available
import idt # import to make 'setIDT' available
import vga

proc archInit*(): void =
  clear()
