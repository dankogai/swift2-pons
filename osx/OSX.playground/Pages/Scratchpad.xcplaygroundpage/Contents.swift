//: [Previous](@previous)
import PONS

/*
let bi:BigInt = 1<<256-1
var bq = BigInt(1).over(bi)
// bq = 0.1
bq / Rational(Double.sqrt(2.0))
typealias BigRat = Rational<BigInt>
BigRat(2.0)
2.0.precision
BigInt(1).over(bi).precision

var v:BigRat = 0.5
v + v//: [Next](@next)
BigRat.log(10)
sizeofValue(1.over(2))
//let M61 = BigUInt(1)<<61 - 1
//let M127 = BigUInt(1)<<127 - 1
//let (q, r) = BigUInt.divmod(M127, M61)
//q
//r
let umax128 = BigUInt(1) << 128 - 1
let umax64 = BigUInt(1) << 64 - 1
//BigUInt.gcd(umax128,umax64)
// POUtil.Constants.E["Rational<BigUInt>"]![128]
// Rational.exp(BigInt(1).over(1))
// Rational.exp(BigInt(2).over(1))
// Rational.exp(BigInt(1).over(1), precision:1024)
// POUtil.Constants.E
//Rational.atan(BigInt(1).over(1), precision:128)*4
let rbone = BigInt(1).over(1)
Rational.exp(rbone)
Rational.atan(rbone)
Rational.atan2(-rbone, rbone)
Rational.atan2(Rational.infinity, rbone).toDouble()

import Foundation
String(format:"%a", Double.pi())
String(format:"%a", Double.PI)
String(format:"%a", BigRat.pi().toDouble() - Double.PI)
// Rational.exp(rbone, precision:512)

POUtil.constants
Rational.sqrt(BigInt(1).over(2))
let pi_4 = BigRat.pi(128)/4

Rational.cos(BigInt(1).over(2))
Rational.sin(BigInt(1).over(2))
Rational.tan(BigInt(1).over(2))
Rational.cos(pi_4)
Rational.sin(pi_4)
Rational.tan(pi_4)
Rational.cos(-pi_4)
Rational.sin(-pi_4)
Rational.tan(-pi_4)
print(POUtil.constants)
*/
/*
func fact<T:POInteger>(n:T)->T {
    return n < 2 ? 1 : (2...n).reduce(1, combine:*)
}
*/
//var pi128 = BigRat.pi(128)
//var pi128 = BigInt("68417829380157871863019543882359730131241")
//    .over(BigInt("21778071482940061661655974875633165533184"))
//Complex.exp(pi128.i).imag.toFPString()

//Complex.sqrt(BigRat(-2)).im.toFPString()
//let bpi = BigInt("3141592653589793238462643383279502884197169")
//    .over(BigInt("1000000000000000000000000000000000000000000"))
Complex.exp(BigRat.pi(128).i)
BigRat.tan(BigRat.pi()/2.0)
BigRat.sin(BigRat.pi(128)/1.0)
Double.atan(Double.infinity)
BigRat.atan(BigRat.infinity).toFPString()
import Foundation
1.0/(-1.0/0.0)
BigRat.infinity.reciprocal

