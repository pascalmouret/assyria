import paging.allocator
import arch_constants

import options
import math

# TODO: use built-in list (requires new and other magic)
type
  Block = object
    base: pointer
    size: csize
    next: ptr Block
    prev: ptr Block

var freeBlocks: ptr Block = nil
var usedBlocks: ptr Block = nil


proc alloc*(size: int): pointer


proc initMem*(): void =
  var 
    firstPage: pointer = allocatePage()
    sizeOfBlock: int = sizeOf(Block)
    blockPtr: ptr Block = cast[ptr Block](firstPage)
  blockPtr.base = cast[pointer](cast[uint32](firstPage) + sizeOfBlock.uint32)
  blockPtr.size = PAGE_SIZE - sizeOfBlock
  blockPtr.next = nil
  blockPtr.prev = nil
  freeBlocks = blockPtr


proc newBlock(base: pointer, size: csize, next: ptr Block, prev: ptr Block): ptr Block =
  result = cast[ptr Block](alloc(sizeOf(Block)))
  result[] = Block(base: base, size: size, next: next, prev: prev)
  return result


proc newBlock(base: uint32, size: csize, next: ptr Block, prev: ptr Block): ptr Block =
  result = newBlock(cast[pointer](base), size, next, prev)


proc findFreeBlock(size: csize): ptr Block =
  var 
    current: ptr Block = freeBlocks
  while current != nil:
    if current.size >= size:
      return current
    current = current.next


proc findUsedBlock(p: pointer): ptr Block =
  var 
    current: ptr Block = usedBlocks
  while current != nil:
    if current.base == p:
      return current
    current = current.next


proc free*(p: pointer): void =
  var usedBlock = findUsedBlock(p)
  if usedBlock != nil:
    if usedBlock.prev != nil:
      usedBlock.prev.next = usedBlock.next
    elif usedBlock.next != nil:
      usedBlocks = usedBlock.next
    else:
      usedBlocks = nil
    usedBlock.next = freeBlocks
    freeBlocks = usedBlock


# TODO: allow allocation of area bigger than one page
proc alloc*(size: csize): pointer =
  var
    totalSize = size + sizeOf(Block)
    freeBlock = findFreeBlock(totalSize)
  if freeBlock != nil:
    var
      usedBlock = cast[ptr Block](cast[csize](freeBlock.base) + size)
    usedBlock[] = Block(base: freeBlock.base, size: size, next: usedBlocks, prev: nil)
    usedBlocks = usedBlock
    result = usedBlock.base
    if freeBlock.size == totalSize and (freeBlock.next != nil or freeBlock.prev != nil):
      if freeBlock.prev != nil:
        freeBlock.prev.next = freeBlock.next
        free(freeBlock)
      elif freeBlock.next != nil:
        freeBlocks = freeBlock.next
        free(freeBlock)
    else:
      freeBlock.size = freeBlock.size - totalSize
      freeBlock.base = cast[pointer](cast[uint32](freeBlock.base) + size.uint32)
  else:
    var newPage = allocatePage()
    if newPage == nil:
      return nil
    freeBlocks = newBlock(
      allocatePage(),
      PAGE_SIZE,
      freeBlocks,
      nil
    )
    return alloc(size)
  return result
