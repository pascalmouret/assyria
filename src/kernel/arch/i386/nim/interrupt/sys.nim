import io

proc testInterruptHandler(p: pointer): void {.interrupt.} =
  println("handling the answer to life, the universe and everything.")
