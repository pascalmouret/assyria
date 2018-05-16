import paging.types


proc physicalAddress*(frame: FrameAddress): pointer =
  return cast[pointer](frame.csize * PAGE_SIZE)