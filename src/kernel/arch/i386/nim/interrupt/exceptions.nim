import io
import idt

proc halt(): void =
  asm """
    hlt
  """

proc divideByZeroException(p: ptr IFrame): void {.interrupt.} =
  println("divide by zero")
  halt()

proc debugException(p: ptr IFrame): void {.interrupt.} =
  println("debug exception")
  halt()

proc nonMaskableInterruptException(p: ptr IFrame): void {.interrupt.} =
  println("non maskable interrupt")
  halt()

proc breakpointException(p: ptr IFrame): void {.interrupt.} =
  println("breakpoint")
  halt()

proc overflowException(p: ptr IFrame): void {.interrupt.} =
  println("overflow")
  halt()

proc boundRangeExceededException(p: ptr IFrame): void {.interrupt.} =
  println("bound range exceeded")
  halt()

proc invalidOpcodeException(p: ptr IFrame): void {.interrupt.} =
  println("invalid opcode")
  halt()

proc deviceNotAvailableException(p: ptr IFrame): void {.interrupt.} =
  println("device not available")
  halt()

proc doubleFaultException(p: ptr IFrame, er: cuint): void {.interrupt.} =
  println("double fault")
  halt()

proc coprocessorSegmentOverrunException(p: ptr IFrame): void {.interrupt.} =
  println("coprocessor segment overrun")
  halt()

proc invalidTSSException(p: ptr IFrame, ec: cuint): void {.interrupt.} =
  println("invalid tss")
  halt()

proc segmentNotPresentException(p: ptr IFrame, ec: cuint): void {.interrupt.} =
  println("segment not present")
  halt()

proc stackSegmentFaultException(p: ptr IFrame, ec: cuint): void {.interrupt.} =
  println("stack segment fault")
  halt()

proc generalProtectionFaultException(p: ptr IFrame, ec: cuint): void {.interrupt.} =
  println("general protection fault")
  halt()

proc pageFaultException(p: ptr IFrame, ec: cuint): void {.interrupt.} =
  println("page fault")
  halt()

proc x87FloatingPointException(p: ptr IFrame): void {.interrupt.} =
  println("x87 floating point")
  halt()

proc alignmentCheckException(p: ptr IFrame, ec: cuint): void {.interrupt.} =
  println("alignment check")
  halt()

proc machineCheckException(p: ptr IFrame): void {.interrupt.} =
  println("machine check")
  halt()

proc SIMDFloatingPointException(p: ptr IFrame): void {.interrupt.} =
  println("simd floating point")
  halt()

proc virtualizationException(p: ptr IFrame): void {.interrupt.} =
  println("virtualization")
  halt()

proc securityException(p: ptr IFrame, ec: cuint): void {.interrupt.} =
  println("virtualization")
  halt()

proc FPUErrorException(p: ptr IFrame, ec: cuint): void {.interrupt.} =
  println("fpu error")
  halt()
