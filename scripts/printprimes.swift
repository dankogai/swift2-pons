#!/usr/bin/env swift -I. -L. -lPONS
import PONS
var upto = 8
if 1 < Process.arguments.count {
   if let n = Int(Process.arguments[1]) {
       upto = max(n, upto)
   }
}
for i in 2...upto {
    if i.isPrime { print(i) }
}
