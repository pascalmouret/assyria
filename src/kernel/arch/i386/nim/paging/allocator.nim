import multiboot

import math

const PAGE_SIZE = 4096

#[
Start and end addresses of the kernel image in RAM. Necessary to avoid
writting over it.

They are symbols defined by the linker script and as such don't have a value
by themselves, but one can find their location in memory by getting a pointer
to the symbol.
]#
var kernelStart {.header: "<externals.h>", importc: "ldKernelStartSymbol"}: uint8
var kernelEnd {.header: "<externals.h>", importc: "ldKernelEndSymbol"}: uint8
var kernelStartAddr: pointer
var kernelEndAddr: pointer

type
  # the actual address is only 20 bit long, but for simplicities sake
  FrameAddress = distinct uint32
  FrameStack = UncheckedArray[FrameAddress]

var stackPtr: ptr FrameStack
var freePages: int = 0


proc nextFrameAlignedAddress(address: uint32): uint32 =
  return address + (PAGE_SIZE.uint32 - (address mod PAGE_SIZE))


proc frameAddress(address: uint32): FrameAddress =
  return cast[FrameAddress](address div PAGE_SIZE)


proc isKernelFrame(frame: FrameAddress): bool =
  return frame.uint32 * PAGE_SIZE >= cast[uint32](kernelStartAddr) and frame.uint32 * PAGE_SIZE <= cast[uint32](kernelEndAddr)


proc freePage*(page: FrameAddress): void = 
  stackPtr[freePages] = page
  inc(freePages)


proc allocatePage*: pointer =
  dec(freePages)
  return cast[pointer](stackPtr[freePages].uint32 * PAGE_SIZE)


proc initMemoryBlock(base: uint32, limit: uint32): void =
  var
    currentFrame: FrameAddress = frameAddress(nextFrameAlignedAddress(base))
    nextFrame: FrameAddress = cast[FrameAddress](currentFrame.uint32 + PAGE_SIZE)
  while nextFrame.uint <= limit:
    if not isKernelFrame(currentFrame):
      freePage(currentFrame)
    currentFrame = nextFrame
    nextFrame = cast[FrameAddress](currentFrame.uint32 + PAGE_SIZE)


proc fillStack(mmap: MMap, entries: int): void =
  var i: int = 0

  while i < entries:
    if mmap[i].kind == MMapEntryKind.Usable:
      initMemoryBlock(mmap[i].base.uint32, mmap[i].limit.uint32)
    inc(i)


proc initPageStack*(mmap: MMap, mmapSize: uint32): void =
  var mmapEntries = mmapSize div mmap[1].size.uint32
  kernelStartAddr = addr kernelStart
  kernelEndAddr = addr kernelEnd
  stackPtr = cast[ptr FrameStack](kernelEndAddr)
  fillStack(mmap, mmapEntries.int)
