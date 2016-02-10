/*:
# Welcome to PONS!

Welcome to pons, a protocol-oriented number system for swift, purely by swift.

![](https://github.com/dankogai/swift-pons/raw/master/typetree.png)

## Getting Started

If you have not built `PONS.framework` yet, choose `Framework-OSX` as the scheme and build it.
When the build is done, come back and enjoy!

*/

//: ## SYNOPSIS

import PONS                     // Let the fun begin!

//: BigInt included.  Enjoy unlimited!

let bn = BigInt(1)<<64 + 1      // 18446744073709551617
bn.asUInt64                     // nil; bn > UIntMax.max
(bn - 2).asUInt64               // 18446744073709551615 == UIntMax.max
bn + bn // 36893488147419103234
bn - bn // 0
bn * bn // 340282366920938463500268095579187314689
bn / bn // 1

//: Rational (number type) is also included.

let bq = BigInt(1).over(bn)     // (1/18446744073709551617)
bq + bq // (2/18446744073709551617)
bq - bq // (0/1)
bq * bq // (1/340282366920938463500268095579187314689)
bq / bq // (1/1)
bq.denominator == bn            // true, of course!
bq.reciprocal.numerator == bn   // so is this

//: Complex numbers.  How can we live without them?

let bz = bq + bq.i  // ((1/18446744073709551617)+(1/18446744073709551617).i)
bz + bz // ((2/18446744073709551617)+(2/18446744073709551617).i)
bz - bz // ((0/1)+(0/1).i)
bz * bz // ((0/1)+(2/340282366920938463500268095579187314689).i)
bz / bz // ((1/1)+(0/1).i)

//: [Next](@next)
