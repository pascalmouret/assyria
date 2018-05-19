import paging.types

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
  ReservedMemoryMap = array[4, ReservedMemory]

var stackPtr: ptr FrameStack = cast[ptr FrameStack](addr kernelEnd)
var freePages: int = 0
# initalised in initPageStack
var reservedMemoryMap: ReservedMemoryMap

#[
A map of all memory regions which should not be put on the stack because they already hold
important information.
Not built during nim init because we need multiboot information.
]#
proc buildReservedMemoryMap(): ReservedMemoryMap =
  return [
    # lower memory
    ReservedMemory(
      base: cast[pointer](0x0),
      size: 0x100000
    ),
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
  return cast[pointer](
    cast[csize](address) + (PAGE_SIZE.csize - (cast[csize](address) mod PAGE_SIZE))
  )


proc frameAddress(address: pointer): FrameAddress =
  return cast[FrameAddress](cast[csize](address) div PAGE_SIZE.csize)


proc physicalAddress(frame: FrameAddress): pointer =
  return cast[pointer](frame.csize * PAGE_SIZE)


proc isReservedFrame(frame: FrameAddress): bool =
  var physicalAddress = cast[csize](physicalAddress(frame))
  for entry in reservedMemoryMap:
    if (physicalAddress >= cast[csize](entry.base) and 
        physicalAddress + PAGE_SIZE <= cast[csize](entry.base) + entry.size):
      # TODO: add kernel page
        return true
  return false


proc freePage*(page: FrameAddress): void = 
  stackPtr[freePages] = page
  inc(freePages)


proc allocatePageFrame*: FrameAddress =
  # if freePages == 0:
    # return nil
  dec(freePages)
  return stackPtr[freePages]


# tmp
# TODO: allow allocation of multiple pages
# TODO: return virtual address, not physical
proc allocatePage*: pointer =
  return physicalAddress(allocatePageFrame())


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


# remove the pages filled up with the page stack
proc removeStackFrames(): void =
  var
    base: csize = cast[csize](stackPtr)
    size: csize = freePages * sizeOf(FrameAddress)
    oldStackCount = 0
    newStackCount = oldStackCount
  while oldStackCount < freePages:
    var 
      physicalAddress = cast[csize](physicalAddress(stackPtr[oldStackCount]))
    if not (physicalAddress >= base and physicalAddress <= base + size):
      inc(newStackCount)
      stackPtr[newStackCount] = stackPtr[oldStackCount]
    inc(oldStackCount)
  freePages = newStackCount


proc initPageStack*(): void =
  var 
    mmapEntries = multibootInfoPtr.mmapLength.csize div multibootInfoPtr.mmapPtr[0].size.csize
  reservedMemoryMap = buildReservedMemoryMap()
  stackPtr = cast[ptr FrameStack](addr kernelEnd)
  fillStack(multibootInfoPtr.mmapPtr[], mmapEntries.int)
  removeStackFrames()
