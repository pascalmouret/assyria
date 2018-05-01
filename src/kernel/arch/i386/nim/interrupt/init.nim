{.passC: "-mgeneral-regs-only".}

include interrupt.sys

import idt
import constants

proc interruptInit*(): void =
  registerInterrupt(0x42.uint, newIDTTypeAttr(IDTType.Int32, false, DPL.Ring0, true), cast[IntProc](testInterruptHandler))
