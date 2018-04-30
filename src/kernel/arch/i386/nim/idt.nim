import constants

import unsigned

type
  IDTType = enum
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

proc setIDT(idtPtr: ptr IDT): void {.exportc.} =
  discard

proc newIDTEntry(typeAttr: IDTTypeAttr, f: void -> void): IDTEntry =
  newIDTEntry(typeAttr, cast[uint32](f), DataSegment.Code)

proc newIDTEntry(typeAttr: IDTTypeAttr, offset: uint32, seg: uint16): IDTEntry =
  var entry: IDTEntry = cast[IDTEntry](0.uint64) # trick compiler into allocating on stack
  entry.offset1 = offset.uint16
  entry.offset2 = (offset shr 16).uint16
  entry.segSelector = seg
  entry.typeAttr = typeAttr
  return entry

proc newIDTTypeAttr(kind: IDTType, storage: bool, dpl: DPL, active: bool): IDTTypeAttr =
  var result = 0.uint8
  result = result or cast[uint8](kind)
  result = result or (cast[uint8](ord(storage)) shl 4)
  result = result or (cast[uint8](ord(dpl)) shl 5)
  result = result or (cast[uint8](ord(active)) shl 7)
  return cast[IDTTypeAttr](result)
