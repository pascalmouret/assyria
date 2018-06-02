type
  # the actual address is only 20 bit long, but for simplicities sake it's 32 bits for now
  FrameAddress* = distinct uint32
  PageAddress* = distinct uint32

const NO_FREE_PAGES* = cast[PageAddress](0xFFFFF)

proc `==`*(x, y: PageAddress): bool =
  return cast[uint32](x) == cast[uint32](y)