import paging.allocator
import arch_constants
import io

import options
import math

type
  Block = object
    base: pointer
    size: int
    next: ptr Block
    prev: ptr Block

var blocks: ptr Block = nil


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
  blocks = blockPtr


proc newBlock(base: pointer, size: int, next: ptr Block, prev: ptr Block): ptr Block =
  result = cast[ptr Block](alloc(sizeOf(Block)))
  result[] = Block(base: base, size: size, next: next, prev: prev)
  return result


proc newBlock(base: uint32, size: int, next: ptr Block, prev: ptr Block): ptr Block =
  result = newBlock(cast[pointer](base), size, next, prev)


proc findBlock(size: int): ptr Block =
  var 
    current: ptr Block = blocks
  while current != nil:
    if current.size >= size:
      return current
    current = current.next


proc free*(add: pointer, size: int): void =
  blocks = newBlock(add, size, blocks, nil)


proc free*[T](add: ptr T): void =
  free(cast[pointer](add), sizeOf(T))


# TODO: allow allocation of area bigger than one page
proc alloc*(size: int): pointer =
  var bestBlock = findBlock(size)
  if bestBlock != nil:
    result = bestBlock.base
    if bestBlock.size == size and (bestBlock.next != nil or bestBlock.prev != nil):
      if bestBlock.prev != nil:
        bestBlock.prev.next = bestBlock.next
        free(bestBlock)
      elif bestBlock.next != nil:
        blocks = bestBlock.next
        free(bestBlock)
    else:
      bestBlock.size = bestBlock.size - size
      bestBlock.base = cast[pointer](cast[uint32](bestBlock.base) + size.uint32)
  else:
    blocks = newBlock(
      allocatePage(),
      PAGE_SIZE,
      blocks,
      nil
    )
    return alloc(size)
  return result
