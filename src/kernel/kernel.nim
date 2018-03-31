import io

proc kernel_main(): void {.exportc.} =
  init()
  println("Hello, NIM Kernel!")
  println("version 0.0.0.0.0.1")
