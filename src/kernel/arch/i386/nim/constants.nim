type
  DPL* = enum
    Ring0,
    Ring1,
    Ring2,
    Ring3
  DataSegment {.size: sizeOf(uint16).}= enum
    Null = 0x0
    Code = 0x8
    Data = 0x10
