import arch_constants
import paging.allocator
import paging.types
import io

type
  #[
  Page Directory Entry Structure
    bit 0     : present
    bit 1     : read/write
    bit 2     : user
    bit 3     : write through
    bit 4     : cache disabled
    bit 5     : accessed
    bit 6     : always 0 (reserved)
    bit 7     : page size (0 for 4k, 1 for 4m)
    bit 8     : ignored
    bit 9-11  : custom
    bit 12-31 : page table frame address
  ]#
  PageDirectoryEntry = distinct uint32
  PageDirectory = array[1024, PageDirectoryEntry]
  #[
  Page Directory Entry Structure
    bit 0     : present
    bit 1     : read/write
    bit 2     : user
    bit 3     : write through
    bit 4     : cache disabled
    bit 5     : accessed
    bit 6     : dirty
    bit 7     : always 0 (reserved)
    bit 8     : global
    bit 9-11  : custom
    bit 12-31 : physical page address
  ]#
  PageTableEntry = distinct uint32
  PageTable = array[1024, PageTableEntry]


const PTABLE_PAGE_INDEX = 1022


const pageDirectory: ptr PageDirectory = cast[ptr PageDirectory](0xFFFFF000)
const ptablePage: ptr PageTable = cast[ptr PageTable](0xFFBFF000)


proc pagingInit*: void
proc allocatePage*(num: int = 1): pointer


proc pageDirectoryEntry(
  present: bool, 
  rw: bool, 
  user: bool, 
  writeThrough: bool, 
  cacheDisabled: bool, 
  bigPage: bool,
  ignored: bool,
  frameAddress: FrameAddress
): PageDirectoryEntry =
  var result = 0.uint32
  result = result or present.uint32
  result = result or (rw.uint32 shl 1)
  result = result or (user.uint32 shl 2)
  result = result or (writeThrough.uint32 shl 3)
  result = result or (cacheDisabled.uint32 shl 4)
  result = result or (bigPage.uint32 shl 7)
  result = result or (ignored.uint32 shl 8)
  result = result or (frameAddress.uint32 shl 11)
  return cast[PageDirectoryEntry](result)


proc pageTableEntry(
  present: bool, 
  rw: bool, 
  user: bool, 
  writeThrough: bool, 
  cacheDisabled: bool, 
  global: bool,
  frameAddress: FrameAddress
): PageTableEntry =
  var result = 0.uint32
  result = result or present.uint32
  result = result or (rw.uint32 shl 1)
  result = result or (user.uint32 shl 2)
  result = result or (writeThrough.uint32 shl 3)
  result = result or (cacheDisabled.uint32 shl 4)
  result = result or (global.uint32 shl 8)
  result = result or (frameAddress.uint32 shl 11)
  return cast[PageTableEntry](result)


proc pageAddress(pdirIndex: int, ptableIndex: int): PageAddress =
  return cast[PageAddress]((pdirIndex.uint32 shl 10) or ptableIndex.uint32)


proc virtualAddressPointer(pageAddress: PageAddress): pointer =
  return cast[pointer](pageAddress.uint32 shl 12)


proc virtualAddressPointer(pdirIndex: int, ptableIndex: int, offset: int = 0): pointer =
  return cast[pointer](((pdirIndex.uint32 shl 22) or (ptableIndex.uint32 shl 12)) + offset.uint32)


proc getPtable(pdirIndex: int): ptr PageTable =
  return cast[ptr PageTable](virtualAddressPointer(PTABLE_PAGE_INDEX, pdirIndex))
  

proc pdirIndex(pageAddress: PageAddress): int =
  return (cast[uint32](pageAddress) shr 10).int


proc ptableIndex(pageAddress: PageAddress): int =
  return (cast[uint32](pageAddress) and 0x39F).int # only first ten bits


proc isPresent(pdirEntry: PageDirectoryEntry): bool =
  return cast[bool](cast[uint32](pdirEntry) and 1)


proc isPresent(ptableEntry: PageTableEntry): bool =
  return isPresent(cast[PageDirectoryEntry](ptableEntry))


proc isBigPage(pdirEntry: PageDirectoryEntry): bool =
  return cast[bool](cast[uint32](pdirEntry) and (1 shl 7))


proc isFree(address: PageAddress): bool =
  var
    pageDirectoryEntry = pageDirectory[address.pdirIndex()]
  return (
    pageDirectoryEntry.isPresent() or 
    (not pageDirectoryEntry.isBigPage() and not ptablePage[address.ptableIndex()].isPresent())
  )
    

proc findFreePageAddress(num: int): PageAddress =
  var 
    counter = 0
  result = NO_FREE_PAGES
  for pageAddress in 0 .. 1023 * 1023:
    if cast[PageAddress](pageAddress).isFree():
      if counter == 0:
        result = cast[PageAddress](pageAddress)
      inc(counter)
      if counter == num:
        return result
    else:
      counter = 0
  return NO_FREE_PAGES


proc newPageTable(pdirIndex: int): ptr PageTable =
  var
    pageFrame = allocatePageFrame()
    pageTable = cast[ptr PageTable](virtualAddressPointer(PTABLE_PAGE_INDEX, pdirIndex))
  ptablePage[pdirIndex] = pageTableEntry(true, true, false, false, true, false, pageFrame)
  pageDirectory[pdirIndex] = pageDirectoryEntry(true, true, false, false, true, false, false, pageFrame)
  memset(cast[pointer](pageTable), 0, PAGE_SIZE)
  return pageTable


proc allocatePage(pageAddress: PageAddress): pointer =
  var
    directoryEntry = pageDirectory[pageAddress.pdirIndex()]
    ptable = if directoryEntry.isPresent(): getPtable(pageAddress.pdirIndex()) else: newPageTable(pageAddress.pdirIndex())
  ptable[pageAddress.ptableIndex()] = pageTableEntry(true, true, false, false, true, false, allocatePageFrame())
  return virtualAddressPointer(pageAddress)


proc allocatePage*(num: int = 1): pointer =
  var
    pageAddress = findFreePageAddress(num)
  if pageAddress == NO_FREE_PAGES:
    return nil
  for address in cast[uint32](pageAddress) .. cast[uint32](pageAddress) + num.uint32 - 1:
    discard allocatePage(cast[PageAddress](address))
  return virtualAddressPointer(pageAddress)
    

proc pagingInit*: void =
  initPageStack()
  