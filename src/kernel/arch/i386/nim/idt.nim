import constants
import io

import unsigned

type
  IntProc* = proc(p: pointer): void {.cdecl.}
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

var idt: ptr IDT = cast[ptr IDT](0)

proc newIDTEntry(typeAttr: IDTTypeAttr, offset: uint32, seg: uint16): IDTEntry =
  result = cast[IDTEntry](0.uint64) # trick compiler into allocating on stack
  result.offset1 = offset.uint16
  result.offset2 = (offset shr 16).uint16
  result.segSelector = seg
  result.typeAttr = typeAttr
  return result

proc newIDTEntry(typeAttr: IDTTypeAttr, f: IntProc): IDTEntry =
  return newIDTEntry(typeAttr, cast[uint32](f), ord(DataSegment.Code).uint16)

proc newIDTTypeAttr*(kind: IDTType, storage: bool, dpl: DPL, active: bool): IDTTypeAttr =
  var result = 0.uint8
  result = result or cast[uint8](kind)
  result = result or (cast[uint8](ord(storage)) shl 4)
  result = result or (cast[uint8](ord(dpl)) shl 5)
  result = result or (cast[uint8](ord(active)) shl 7)
  return cast[IDTTypeAttr](result)

proc registerInterrupt*(vector: uint, typeAttr: IDTTypeAttr, f: IntProc): void {.exportc.} =
  if cast[uint32](idt) != 0:
    idt[vector] = newIDTEntry(typeAttr, f)
  else:
    discard # error handling

proc setIDT(idtPtr: ptr IDT): void {.exportc.} =
  idt = idtPtr
