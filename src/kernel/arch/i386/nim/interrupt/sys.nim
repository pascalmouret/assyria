import io

proc testInterruptHandler(p: pointer): void {.codegenDecl: "__attribute__((interrupt)) $# $#$#"} =
  println("handling the answer to life, the universe and everything.")
