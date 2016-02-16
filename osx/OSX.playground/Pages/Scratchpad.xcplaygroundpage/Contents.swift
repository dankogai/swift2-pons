//: [Previous](@previous)
import PONS

func divmodNR(lhs:BigUInt, _ rhs:BigUInt, debug:Bool=false)->(BigUInt, BigUInt) {
    let bits = rhs.msbAt + 1
    var inv0 = rhs
    var inv:BigUInt = BigUInt(1) << BigUInt(bits)
    let two = inv * inv * 2
    for i in 0...bits {
        inv = inv0 * (two - rhs * inv0)     // Newton-Raphson core
        inv >>= BigUInt(inv.msbAt - bits)   // truncate
        if debug {
            print("divmodNR: i=\(i), inv=\(inv.toString(16))")
        }
        if inv == inv0 { break }
        inv0 = inv
    }
    var (q, r) = (BigUInt(0), lhs)
    while r > rhs {
        let q0 = (r * inv) >> BigUInt(bits*2)
        q += q0
        r -= rhs * q0
        if debug {
            print("divmodNR: (q, r)=(\(q), \(r))")
        }
    }
    return r == rhs ? (q + 1, 0) : (q, r)
}

let uint256max = (BigUInt(1)<<1024-1)
let uint128max = (BigUInt(1)<<128-1)
let sint128max = uint128max >> 1
let prime = BigUInt(UInt.max).prevPrime!
({ n, d in
    let (q0, r0) = BigUInt.divmodLongBit(n, d)
    let (q1, r1) = divmodNR(n, d)
    q1
    r1
    q0 == q1
    r0 == r1
})(uint256max, sint128max)

/*
func divmodNR(lhs:BigUInt, _ rhs:BigUInt)->(BigUInt, BigUInt) {
var bits = rhs.msbAt + 1
var x0 = rhs
var x:BigUInt = BigUInt(1) << BigUInt(bits)
let two = x * x * 2
for i in 0...bits {
x = x0 * (two - rhs * x0)
x >>= BigUInt(x.msbAt - bits)
print("i=\(i)")
if x == x0 { break }
x0 = x
}
var db = lhs.msbAt - rhs.msbAt + 1
var r = lhs * x
let r1 = r >> BigUInt(r.msbAt - db)
return (r1, 0)
}
Complex.exp(BigRat.pi().i)
Complex.exp(BigRat.pi(96).i)
Complex.exp(BigRat.pi(128).i)
BigRat.tan(BigRat.pi()/2.0)
BigRat.sin(BigRat.pi(128)/1.0)
POUtil.constants

Double.atan(Double.infinity)
BigRat.atan(BigRat.infinity).toFPString()
import Foundation
1.0/(-1.0/0.0)
BigRat.infinity.reciprocal

func inner_log<R:POReal>(x:R, precision px:Int=64)->R {
    var y0 = R(1)
    var y1 = y0
    for i in 0...(x.precision.msbAt + 1) {
        let ex = R.exp(y0, precision:px)
        //y1 =  y0
        y1 += R(2) * (x - ex)/(x + ex)
        y1.truncate(px + 32)
        print("y0=\(y0.toFPString()), y1=\(y1.toFPString())")
        if y0 == y1 { break }
        y0 = y1
    }
    return y1.truncate(px)
}

inner_log(BigRat(2))

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
