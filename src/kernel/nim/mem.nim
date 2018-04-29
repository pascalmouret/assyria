import multiboot

import options

type
  Block = object
    size*: uint32
    next: Option[ptr Block]

var blocks: ptr Block

proc init*(mmap: MMap, entries: uint32): Block =
  var i = (entries div sizeOf(MMapEntry).uint32).int - 1
  while i >= 0:
    if mmap[i].kind == MMapEntryKind.Usable:
      var blocks = cast[ptr Block](mmap[i].base)
      blocks[] = Block(size: mmap[i].limit.uint32, next: none(ptr Block))
      break
    dec(i)
  blocks[]
