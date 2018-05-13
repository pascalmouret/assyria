#[
GCC does not allow the usage of special registers while in interrupt code, so
we suppress the usage of those for this file (also why include is used for
the other other files).
]#
{.passC: "-mgeneral-regs-only".}
#[
Interrupts do not behave like common functions in C, for one the register state
has to be preserved, for the other we come back from it using the "iret"
command, not "ret" or "leave". Luckily, GCC can do all of that for us and NIM
allows us to rewritte the function declaration accordingly.
The cdecl pragma is required to get a proper pointer.
]#
{.pragma: interrupt, codegenDecl: "__attribute__((interrupt)) $# $#$#", cdecl.}

include interrupt.sys
include interrupt.exceptions

import idt
import arch_constants


proc interruptInit*(): void =
  registerInterrupt(0x0.uint, newIDTTypeAttr(IDTType.Trap32, false, DPL.Ring0, true), divideByZeroException)
  registerInterrupt(0x1.uint, newIDTTypeAttr(IDTType.Trap32, false, DPL.Ring0, true), debugException)
  registerInterrupt(0x2.uint, newIDTTypeAttr(IDTType.Trap32, false, DPL.Ring0, true), nonMaskableInterruptException)
  registerInterrupt(0x3.uint, newIDTTypeAttr(IDTType.Trap32, false, DPL.Ring0, true), breakpointException)
  registerInterrupt(0x4.uint, newIDTTypeAttr(IDTType.Trap32, false, DPL.Ring0, true), overflowException)
  registerInterrupt(0x5.uint, newIDTTypeAttr(IDTType.Trap32, false, DPL.Ring0, true), boundRangeExceededException)
  registerInterrupt(0x6.uint, newIDTTypeAttr(IDTType.Trap32, false, DPL.Ring0, true), invalidOpcodeException)
  registerInterrupt(0x7.uint, newIDTTypeAttr(IDTType.Trap32, false, DPL.Ring0, true), deviceNotAvailableException)
  registerFault(0x8.uint, newIDTTypeAttr(IDTType.Trap32, false, DPL.Ring0, true), doubleFaultException)
  registerInterrupt(0x9.uint, newIDTTypeAttr(IDTType.Trap32, false, DPL.Ring0, true), coprocessorSegmentOverrunException)
  registerFault(0xA.uint, newIDTTypeAttr(IDTType.Trap32, false, DPL.Ring0, true), invalidTSSException)
  registerFault(0xB.uint, newIDTTypeAttr(IDTType.Trap32, false, DPL.Ring0, true), segmentNotPresentException)
  registerFault(0xC.uint, newIDTTypeAttr(IDTType.Trap32, false, DPL.Ring0, true), stackSegmentFaultException)
  registerFault(0xD.uint, newIDTTypeAttr(IDTType.Trap32, false, DPL.Ring0, true), generalProtectionFaultException)
  registerFault(0xE.uint, newIDTTypeAttr(IDTType.Trap32, false, DPL.Ring0, true), pageFaultException)
  registerInterrupt(0x10.uint, newIDTTypeAttr(IDTType.Trap32, false, DPL.Ring0, true), x87FloatingPointException)
  registerFault(0x11.uint, newIDTTypeAttr(IDTType.Trap32, false, DPL.Ring0, true), alignmentCheckException)
  registerInterrupt(0x12.uint, newIDTTypeAttr(IDTType.Trap32, false, DPL.Ring0, true), machineCheckException)
  registerInterrupt(0x13.uint, newIDTTypeAttr(IDTType.Trap32, false, DPL.Ring0, true), SIMDFloatingPointException)
  registerInterrupt(0x24.uint, newIDTTypeAttr(IDTType.Trap32, false, DPL.Ring0, true), virtualizationException)
  registerFault(0x1E.uint, newIDTTypeAttr(IDTType.Trap32, false, DPL.Ring0, true), securityException)

  registerInterrupt(0x42.uint, newIDTTypeAttr(IDTType.Int32, false, DPL.Ring0, true), testInterruptHandler)
