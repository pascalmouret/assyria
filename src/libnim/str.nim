import math
import io

proc length(i: int, base: int): int =
  result = 1
  var remove = 10
  while (i - (base^result) > 0):
    inc(result)
  return result

proc printIntRec(i: int, base: int): void =
  if (i > 0):
    let digit = i %% base
    printIntRec(((i - digit) / base).int, base)
    print(char((if digit > 9: ord('A') - 10 else: ord('0')) + digit))

proc printInt*(i: int, base: int): void =
  var
    tmp: int
    negative: bool

  if (negative):
    tmp = i * -1
  else:
    tmp = i

  if negative:
    print('-')

  if tmp > 0:
    printIntRec(tmp, base)
  else:
    print('0')

  print('\n')
