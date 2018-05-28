import arch_constants
import io

import unsigned

type
  IFrame* = object
    eflags*: uint16
    unused*: uint8
    cs*: uint8
    eip*: uint16
  #[
  Interrupt and Fault handlers need to use the {.cdecl.} pragma to get a
  compatible pointer.
  ]#
  IntProc = proc(p: ptr IFrame): void {.cdecl.}
  #[
  This type is needed because some x86 exceptions also push an error code onto
  the stack.
  ]#
  FaultProc = proc(p: ptr IFrame, ec: cuint): void {.cdecl.}
  IDTType* = enum
    Task32 = 0x5,
    Int16 = 0x6,
    Trap16 = 0x7,
    Int32 = 0xE,
    Trap32 = 0xF
  #[
  IDT Type Attribute Structure:
    0 - 3 : Type
    4     : Storage Segment
    5 - 6 : DPL
    7     : Present
  ]#
  IDTTypeAttr = distinct uint8
  IDTEntry = object
    offset1: uint16 # 0 - 15
    segSelector: uint16
    zero: uint8
    typeAttr: IDTTypeAttr
    offset2: uint16 # 16 - 31
  IDT = array[256, IDTEntry]


# set to correct value by setIDT, called from assembly
var idt: ptr IDT = cast[ptr IDT](0)


proc newIDTEntry(typeAttr: IDTTypeAttr, offset: uint32, seg: uint16): IDTEntry =
  result = cast[IDTEntry](0.uint64) # trick compiler into allocating on stack
  result.offset1 = offset.uint16
  result.offset2 = (offset shr 16).uint16
  result.segSelector = seg
  result.typeAttr = typeAttr
  return result


proc newIDTEntry(typeAttr: IDTTypeAttr, f: uint32): IDTEntry =
  return newIDTEntry(typeAttr, f, ord(DataSegment.Code).uint16)


proc newIDTTypeAttr*(kind: IDTType, storage: bool, dpl: DPL, active: bool): IDTTypeAttr =
  var result = 0.uint8
  result = result or cast[uint8](kind)
  result = result or (cast[uint8](ord(storage)) shl 4)
  result = result or (cast[uint8](ord(dpl)) shl 5)
  result = result or (cast[uint8](ord(active)) shl 7)
  return cast[IDTTypeAttr](result)


proc registerInterrupt*(vector: uint, typeAttr: IDTTypeAttr, f: IntProc): void {.exportc.} =
  if cast[uint32](idt) != 0: # make sure idt is set
    idt[vector] = newIDTEntry(typeAttr, cast[uint32](f))
  else:
    discard # error handling


proc registerFault*(vector: uint, typeAttr: IDTTypeAttr, f: FaultProc): void {.exportc.} =
  if cast[uint32](idt) != 0: # make sure idt is set
    idt[vector] = newIDTEntry(typeAttr, cast[uint32](f))
  else:
    discard # error handling


proc setIDT(idtPtr: ptr IDT): void {.exportc.} =
  idt = idtPtr
