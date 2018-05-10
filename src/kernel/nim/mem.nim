import multiboot

import options

type
  Block = object
    base*: uint32
    size*: uint32
    next: Option[ptr Block]

var blocks: ptr Block

let kernelStart {.header: "<externals.h>", importc: "ldKernelStartSymbol"}: cchar
let kernelEnd {.header: "<externals.h>", importc: "ldKernelEndSymbol"}: cchar

proc initialListSize(mmap: MMap): int =
  var
    i = (entries div sizeOf(MMapEntry).uint32).int - 1
    c = 0

  while i >= 0:
    if mmap[i].kind = MMapEntryKind.Usable:
      c = c + 1
    dec(i)

  return c * sizeOf(Block)

proc init*(mmap: MMap, size: uint32): Block =
  var
    i = (entries div sizeOf(MMapEntry).uint32).int - 1
    listSize = initialListSize(mmap)
  while i >= 0:
    if mmap[i].kind == MMapEntryKind.Usable && mmap[i].size >= initialListSize:
      blocks = cast[ptr Block](mmap[i].base)
      blocks[] = Block(base: mmap[i].base.uint32, size: mmap[i].limit.uint32, next: none(ptr Block))
      break
    dec(i)
  blocks[]

proc buildBlocksStartingFrom(mPtr: pointer, mmap: Mmap, size: uint32): Block =
  var
    i: int = (entries div sizeOf(MMapEntry).uint32).int - 1
    curPtr: ptr Block = cast[ptr Block](mPtr)
    prevPtr: ptr Block = cast[ptr Block](0)

  while i >= 0:
    if mmap[i].kind = MMapEntryKind.Usable:
      curPtr[] = Block(base: mmap[i].base.uint32, size: mmap[i].limit.uint32, next: none(ptr Block))
      if cast[int](prev) > 0:
        prevPtr[].next = some(curPtr)
      else:
        blocks = curPtr
      prevPtr = curPtr
      curPtr = curPtr + sizeOf(Block)
