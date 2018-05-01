{.passC: "-mgeneral-regs-only".}
{.pragma: interrupt, codegenDecl: "__attribute__((interrupt)) $# $#$#", cdecl.}

include interrupt.sys

import idt
import constants

proc interruptInit*(): void =
  registerInterrupt(0x42.uint, newIDTTypeAttr(IDTType.Int32, false, DPL.Ring0, true), testInterruptHandler)
