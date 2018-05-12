import multiboot
import arch_constants

import math

#[
Start and end addresses of the kernel image in RAM. Necessary to avoid
writting over it.

They are symbols defined by the linker script and as such don't have a value
by themselves, but one can find their location in memory by getting a pointer
to the symbol.
]#
var kernelStart {.header: "<externals.h>", importc: "ldKernelStartSymbol"}: uint8
var kernelEnd {.header: "<externals.h>", importc: "ldKernelEndSymbol"}: uint8

type
  # the actual address is only 20 bit long, but for simplicities sake
  FrameAddress = distinct uint32
  FrameStack = UncheckedArray[FrameAddress]
  ReservedMemory = object
    base: pointer
    size: csize

var stackPtr: ptr FrameStack
var freePages: int = 0

#[
A map of all memory regions which should not be put on the stack because they already hold
important information.
TODO: add kernel pages for them
]#
var reservedMemoryMap: array[3, ReservedMemory] = [
  ReservedMemory(
    base: addr kernelStart, 
    size: cast[csize](cast[csize](addr kernelEnd) - cast[csize](addr kernelStart))
  ),
  ReservedMemory(
    base: cast[pointer](multibootInfoPtr),
    size: sizeOf(MultibootInfo)
  ),
  ReservedMemory(
    base: cast[pointer](multibootInfoPtr.mmapPtr),
    size: multibootInfoPtr.mmapLength.csize
  )
]


proc nextFrameAlignedAddress(address: pointer): pointer =
  return cast[pointer](cast[csize](address) + (PAGE_SIZE.csize - (cast[csize](address) mod PAGE_SIZE)))


proc frameAddress(address: pointer): FrameAddress =
  return cast[FrameAddress](cast[csize](address) div PAGE_SIZE.csize)


proc physicalAddress(frame: FrameAddress): pointer =
  return cast[pointer](frame.csize * PAGE_SIZE)


proc isReservedFrame(frame: FrameAddress): bool =
  var physicalAddress = cast[csize](physicalAddress(frame))
  for entry in reservedMemoryMap:
    if physicalAddress >= cast[csize](entry.base) and physicalAddress <= cast[csize](entry.base) + entry.size:
      # TODO: add kernel page
      return true
  return false


# TODO: allow allocation of multiple pages
# TODO: return virtual address, not physical
proc freePage*(page: FrameAddress): void = 
  stackPtr[freePages] = page
  inc(freePages)


proc allocatePage*: pointer =
  dec(freePages)
  return cast[pointer](stackPtr[freePages].csize * PAGE_SIZE)


proc initMemoryBlock(base: pointer, limit: csize): void =
  var
    currentFrame: FrameAddress = frameAddress(nextFrameAlignedAddress(base))
    nextFrame: FrameAddress = cast[FrameAddress](currentFrame.csize + 1)
  while cast[csize](physicalAddress(nextFrame)) <= limit:
    if not isReservedFrame(currentFrame):
      freePage(currentFrame)
    currentFrame = nextFrame
    nextFrame = cast[FrameAddress](currentFrame.csize + PAGE_SIZE)


proc fillStack(mmap: MMap, entries: int): void =
  var i: int = 0

  while i < entries:
    if mmap[i].kind == MMapEntryKind.Usable:
      initMemoryBlock(cast[pointer](mmap[i].base), mmap[i].limit.csize)
    inc(i)


# TODO: pre-allocate pages used for stack
proc initPageStack*(): void =
  var mmapEntries = multibootInfoPtr.mmapLength.csize div multibootInfoPtr.mmapPtr[0].size.csize
  stackPtr = cast[ptr FrameStack](addr kernelEnd)
  fillStack(multibootInfoPtr.mmapPtr[], mmapEntries.int)
