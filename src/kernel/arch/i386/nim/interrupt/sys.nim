import io
import idt


proc testInterruptHandler(p: ptr IFrame): void {.interrupt.} =
  println("handling the answer to life, the universe and everything.")
