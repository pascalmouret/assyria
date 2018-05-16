import paging.allocator
import paging.util


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
  result = 0.uint32
  result = result or present.uint32
  result = result or (rw.uint32 shl 1)
  result = result or (user.uint32 shl 2)
  result = result or (writeThrough.uint32 shl 3)
  result = result or (cacheDisabled.uint32 shl 4)
  result = result or (bigPage.uint32 shl 7)
  result = result or (ignored.uint32 shl 8)
  result = result or (frameAddress.uint32 shl 12)


proc pageTableEntry(
  present: bool, 
  rw: bool, 
  user: bool, 
  writeThrough: bool, 
  cacheDisabled: bool, 
  global: bool,
  frameAddress: FrameAddress
): PageDirectoryEntry =
  result = 0.uint32
  result = result or present.uint32
  result = result or (rw.uint32 shl 1)
  result = result or (user.uint32 shl 2)
  result = result or (writeThrough.uint32 shl 3)
  result = result or (cacheDisabled.uint32 shl 4)
  result = result or (global.uint32 shl 8)
  result = result or (frameAddress.uint32 shl 12)
  

#[
The last entry of a page directory will always point to the page table itself, which
results in the virtual address 0xFFFFF000 pointing to the page directory.
For more information see: https://wiki.osdev.org/Memory_Management_Unit
]#
proc currentPageDirectory: ptr PageDirectory =
  return cast[ptr PageDirectory](0xFFFFF000)


proc tableForDirectoryEntry(entry: ptr DirectoryEntry): ptr PageTable =
  


proc mapFrameToVirtualAddress(virtual: pointer, frame: FrameAddress): pointer =
  var
    dir = currentPageDirectory()



proc identityMapAddresses(start: pointer, size: csize): pointer =
  

proc newKernelDirectory: ptr PageDirectory =
  var
    pageFrame = allocatePageFrame()
    physicalAddress = physicalAddress(pageFrame)
    dir = cast[ptr PageDirectory](physicalAddress)
  memset(physicalAddress(pageFrame), 0, sizeOf(PageDirectory))
  dir[1023] = newDirectoryEntry(true, true, false, false, false, false, pageFrame)


proc initPaging*(): void =
  var kernelDir = newKernelDirectory()
  