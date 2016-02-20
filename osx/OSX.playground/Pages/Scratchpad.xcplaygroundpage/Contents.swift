//: [Previous](@previous)
import PONS
/*

({ r in
BigFloat.log(BigFloat(r))
BigRat.log(BigRat(r)).toDouble()
})(10)

Double.hypot(8.0, 6.0).toFPString()



({ theta in
let (sd, cd) = Double.sincos(Double(theta))
sd
cd
(cd*cd + sd*sd).toFPString()
let (sr, cr) = BigFloat.sincos(BigFloat(theta))
sr
cr
(cr*cr + sr*sr)
BigFloat.sqrt(1 - cr*cr)
BigFloat.sqrt(1 - sr*sr)
//let (sq, cq) = BigRat.sincos(BigRat(theta))
//sq
//cq
//(cq*cq + sq*sq).toFPString()
Complex.exp(BigFloat(theta).i)
})(BigFloat.pi(64,verbose:true) / BigFloat(3))


({ places in
let precision = Int(Double(places) * (Double.log(10)/Double.log(2)))
BigFloat.pi(precision, verbose:true).toFPString(10,places:places)
})(20)

BigFloat.atan(1.5, precision:256)
Double.atan(1.5)
//BigInt.sqrt(2**24, 96)
//BigFloat.sin(BigFloat.pi(128))
//Complex.exp(BigFloat.pi(128).i)
//Complex.exp(BigRat.pi(128).i)
//BigRat.pi(128).i
//BigFloat.exp(-1, precision:128)
//BigFloat.exp(100, precision:256)

({ d , p in
BigFloat.sqrt(BigFloat(d), precision:p)
BigRat.sqrt(BigRat(d), precision:p)
})(Double.PI,64)

({ x in
let t = BigFloat(x)
var (s, c) = BigFloat.sincos(t)
s
c
BigFloat.sin(t)
BigFloat.cos(t)
})(100)

Double.sqrt(2)                  // 1.414213562373095
BigRat.sqrt(2)                  // (112045541949572279837463876455/79228162514264337593543950336)
BigFloat.sqrt(2)                // 1.414213562373095048801688724198
Complex.sqrt(-2)                // (0.0+1.4142135623731.i)
Complex.sqrt(BigRat(-2))        // 112045541949572279837463876455/79228162514264337593543950336).i)
Complex.sqrt(BigFloat(-2))     // ((188437389141110048746221374561/158456325028528675187087900672)+(0/1).i)

import Foundation
let pi1024 = BigFloat.pi(2048,verbose:true)

//let pi1024 = BigFloat.pi(4096, verbose:true)
//print(pi1024)

//BigFloat.sqrt(1)
//var v = BigFloat.sqrt(2)
//BigFloat.sqrt(0.5)

//BigFloat(-0.0) == BigFloat(0.0)

BigFloat.sqrt(4)
BigFloat.sqrt(0.25)
BigFloat(0.5)
BigFloat(0.25)
BigFloat.sqrt(0.25).significand
BigFloat.sqrt(5)

//Complex.exp(BigRat.pi(128))
//var zr=Complex.exp(BigFloat.pi(128).i)
//print(zr)
BigFloat.log(2)
BigFloat.log(10)
BigFloat.pi(128)
BigFloat.sqrt(4)
BigFloat.log(2)

BigFloat(1)/BigFloat(0.25)
//BigFloat.pi(512)
//BigFloat.pi(1024)
//BigFloat.pi(4096, verbose:true)
//Double.PI
//BigFloat.pi(128)
//BigRat.pi(128).toFPString()

//BigFloat(0.5) < BigFloat(0)
//BigFloat.exp(1)

Double.atan(-0.25)
BigFloat.atan(-0.25)
Double.atan(-1)
BigFloat.atan(-1)
Double.atan(1)
BigFloat.atan(1)
BigFloat(-1) < 0
BigFloat(-1) < 1


var e = BigFloat(1)
var n = 1
for i in 1 ... 17 {
n *= i
//e.truncate(64)
let t = BigFloat(1) / BigFloat(n)
print(t)
e += t
}
e
//BigFloat.sqrt(2, precision:128)
//BigFloat.sqrt(2.0, precision:128)

var bf:BigFloat = 42.195
bf.significand
bf.significand.msbAt
bf.exponent
bf.reciprocal()
bf.reciprocal().significand
bf.reciprocal().exponent
bf.reciprocal() * bf

e.precision

BigFloat(Double.PI)
var bf:BigFloat = 42.195
bf.significand.toString(16)
42.195 * 42.195
(bf * bf).toDouble()
(bf * bf).significand.toString(16)

bf.exponent
bf.precision
bf.reciprocal.precision
bf.reciprocal.toDouble()
1/42.195
bf.reciprocal.significand
bf.reciprocal.reciprocal.significand
bf.reciprocal.reciprocal.toDouble()

BigFloat(2.0).toDouble()
BigFloat(2.0).reciprocal.toDouble()
BigFloat(1).precision
BigFloat(7).toDouble()
BigFloat(7).precision
BigFloat(Double.PI).toDouble() == Double.PI
(bf / (2*bf)).toDouble()
BigUInt(7).reciprocal().msbAt
UInt.max.msbAt
var bf:BigFloat = 42.195
bf.toDouble()
bf.asBigRat!
bf = BigFloat(Int.max)
bf.toDouble()
bf.precision
bf.significand.toString(16)
bf.truncate(32)
bf.significand.toString(16)
bf.truncate(32)
bf.significand.toString(16)
bf.truncate(32)
bf.significand.toString(16)
bf = BigFloat(0x1000_0000_0000_0000)
bf.toDouble()
bf.significand.toString(16)
bf.truncate(48)
bf.toDouble()
bf.significand.toString(16)

bf.asBigRat!

BigFloat(1).exponent
BigFloat(1.0).exponent
Double.frexp(1.0)
BigFloat(-1.0).toDouble()
BigFloat(-1.0).significand.unsignedValue
BigFloat(-1.0).exponent
BigFloat(1.0).toDouble()
BigFloat(1.0).significand
BigFloat(1.0).exponent
BigFloat(1.5).toDouble()
BigFloat(1.5).significand
BigFloat(1.5).exponent
BigFloat(-Double.PI).toDouble()
BigFloat(-Double.PI).exponent
BigFloat(-Double.PI).significand
BigFloat(-Double.PI).toDouble()  == -Double.PI
BigFloat(Double.LN2).toDouble()
BigFloat(Double.LN2).exponent
BigFloat(Double.LN2).toDouble() - Double.LN2
//String(format:"%08lx", pihex(13))

///
/// * https://en.wikipedia.org/wiki/Bailey–Borwein–Plouffe_formula
/// * http://en.literateprograms.org/Pi_with_the_BBP_formula_(Python)
///

func pihex(place:Int)->Int {
    func S(i:Int, _ j:Int)->Double {
        func sl(i:Int, _ j:Int)->Double {
            var lhs = 0.0
            for k in 0...i {
                let d = UInt(8*k + j)
                let p = UInt.powmod(16, UInt(i - k), mod:d)
                lhs += Double(p / d) // Double(d)
                lhs %= 1.0
            }
            return lhs
        }
        func sr(i:Int, _ j:Int)->Double {
            var (rhs, rn) = (0.0, 0.0)
            for k in (i+1)..<(i+32){
                rn = rhs + Double.pow(16.0, Double(i-k)) / Double(8*k + j)
                if rhs == rn { break }
                rhs = rn
            }
            return rhs
        }
        return sl(i, j) + sr(i, j)
    }
    let n = place - 1
    let d = (4*S(n,1)-2*S(n,4)-S(n,5)-S(n,6)) % 1.0
    print("d=\(d)")
    return Int(d * 16**14)
}
print(String(format:"%014lx", pihex(1)))
print(String(format:"%014lx", pihex(4)))
//print(String(format:"%014lx", pihex(14)))
//print(String(format:"%014lx", pihex(28)))
print(String(format:"%014lx", pihex(1000)))
*/

/*

var numer = ["0x"]
var denom = ["0x1"]
for i in 0..<4 {
    let d = String(format:"%04x", pihex(1 + 4 * i))
    numer.append(d)
    denom.append("0000")
    print("\(i):\(d)")
}

print(
    (BigRat(3.0)
        + BigInt(numer.joinWithSeparator(""))
    .over(BigInt(denom.joinWithSeparator("")))
    ).toFPString()
)
*/
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
