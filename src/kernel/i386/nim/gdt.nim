type GDTEntry = distinct uint64

#[ 
GDT Access Byte Description (lowest to highest)
  bit 0: accessed (set to 0, CPU will set to 1)
  bit 1: read/write
          - readable bit for code segment
          - writable bit for data segment
  bit 2: direction/conforming
          - direction bit for data (0 = up, 1 = down)
          - conforming bit for code (0 = allow, 1 = disallow)
  bit 3: executable (0 = data segment, 1 = code segment)
  bit 4: always 1
  bit 5 & 6: dpl
  bit 7: present (1 if enabled)
]#
type GDTAccessByte = distinct uint8

#[
GDT Flags Description (lowest to highest)
  bits 0 - 3: part of limit
  bits 4 & 5: unused (0)
  bit 6: granularity (0 = 1b, 1 = 4KiB)
  bit 7: size (0 = 16bit, 1 = 32bit)
]#
type GDTFlags = distinct uint8

type DPL = enum
  Ring0,
  Ring1,
  Ring2,
  Ring3

# external
proc setGDT(gdtPtr: ptr uint, size: uint) {.header: "<asm_routines.h>", varargs.}

# internal
proc buildGDTAccessByte(rw: bool, dc: bool, ex: bool, dpl: DPL): GDTAccessByte
proc buildGDTFlags(gran: bool, size: bool): GDTFlags
proc buildGDTEntry(accessByte: GDTAccessByte, flags: GDTFlags, base: uint32, limit: uint32): GDTEntry

var GDT: array[3, GDTEntry] = [
  # null pointer entry
  cast[GDTEntry](0.uint64),
  # code segment
  buildGDTEntry(buildGDTAccessByte(true, false, true, Ring0), buildGDTFlags(true, true), 0, 0xfffff),
  # data segment
  buildGDTEntry(buildGDTAccessByte(true, false, false, Ring0), buildGDTFlags(true, true), 0, 0xfffff)
]

proc loadGDT*(): void =
  setGDT(cast[ptr uint](addr(GDT)), sizeof(GDT).uint)

proc buildGDTAccessByte(rw: bool, dc: bool, ex: bool, dpl: DPL): GDTAccessByte =
  var accessByte: uint8 = 0b10010000 # present and always set to 1
  if rw:
    accessByte = accessByte or (1 shl 1)
  if dc:
    accessByte = accessByte or (1 shl 2)
  if ex:
    accessByte = accessByte or (1 shl 3)
  accessByte = accessByte or (ord(dc).uint8 shl 5)
  return cast[GDTAccessByte](accessByte)

proc buildGDTFlags(gran: bool, size: bool): GDTFlags =
  var flags: uint8 = 0
  if gran:
    flags = flags or (1 shl 6)
  if size:
    flags = flags or (1 shl 7)
  return cast[GDTFlags](flags)

proc shiftedBase(base: uint32): uint64 =
  var entry = 0.uint64

  let p1 = base and 0xffff # bits 0 - 15
  let p2 = (base shr 16) and 0xff # bits 16 - 23
  let p3 = (base shr 24) and 0xff # bits 24 - 31

  entry = entry or (p1 shl 16)
  entry = entry or (p2 shl 32)
  entry = entry or (p3 shl 56)

  return entry

proc shiftedLimit(limit: uint32): uint64 =
  var entry = 0.uint64

  let p1 = limit and 0xffff # bits 0 - 15
  let p2 = (limit shr 16) and 0xf # bits 16 - 19

  entry = entry or p1
  entry = entry or (p2 shl 48)

  return entry

proc buildGDTEntry(accessByte: GDTAccessByte, flags: GDTFlags, base: uint32, limit: uint32): GDTEntry =
  var entry = 0.uint64

  # add access byte and flags
  entry = entry or (cast[uint32](accessByte) shl 40)
  entry = entry or (cast[uint32](flags) shl 48)

  # add base and limit
  entry = entry or shiftedBase(base)
  if limit > 0xfffff.uint32:
    entry = entry or shiftedLimit(0xfffff) # exception?
  else:
    entry = entry or shiftedLimit(limit)

  return cast[GDTEntry](entry)
