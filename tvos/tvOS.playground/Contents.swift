import UIKit    // this is a tvOS playground
//: ## SYNOPSIS

// import PONS                     // Not needed because it is directly linked

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

/*:
[Elementary function]s (as in `<math.h>`) are supported as static functions.

`POReal` has defalut implementations so you don't have to implement them for your new number types!

`Darwin` and `Glibc` implementations are attached to `Double` as static functions, too.

[Elementary function]: https://en.wikipedia.org/wiki/Elementary_function
*/

Double.sqrt(-1)                 // sadly NaN
Rational.sqrt(bq)               // (1/4294967296) == yes, works with Rational, too!
Complex.sqrt(-1)                // (0.0+1.0.i) // as it should be
Complex.log(-1)                 // (0.0+3.14159265358979.i) // Yes, πi
Complex.exp(Double.PI.i)        // (-1.0+1.22464679914735e-16.i) != (-1.0+0.0.i) // :(
// default 64-bit precision is still not good enough…
Complex.exp(BigRat.pi().i)      // (-(1/1)-(1/4722366482869645213696).i)
// but with 128-bit precision…
Complex.exp(BigRat.pi(128).i)   // (-(1/1)+(0/1).i) // as it should be!

//: [Next](@next)
