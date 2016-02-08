//
//  main.swift
//  pons
//
//  Created by Dan Kogai on 2/4/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

let test = TAP()

// Bool.xor
test.eq(Bool.xor(true,   true), false,  "xor(true, true)   == false")
test.eq(Bool.xor(true,  false), true,   "xor(true, false)  == true")
test.eq(Bool.xor(false,  true), true,   "xor(false, false) == true")
test.eq(Bool.xor(false, false), false,  "xor(false, false) == false")
// POUInt#msbAt
test.eq(UInt64.max.msbAt,   63, "UInt64.max.msbAt == 63")
test.eq(UInt64.min.msbAt,   -1, "UInt64.min.msbAt == -1")
test.eq(UInt32.max.msbAt,   31, "UInt32.max.msbAt == 31")
test.eq(UInt32.min.msbAt,   -1, "UInt32.min.msbAt == -1")
test.eq(UInt16.max.msbAt,   15, "UInt16.max.msbAt == 15")
test.eq(UInt16.min.msbAt,   -1, "UInt16.mix.msbAt == -1")
test.eq(UInt8.max.msbAt,     7, "UInt8.max.msbAt  ==  7")
test.eq(UInt8.min.msbAt,    -1, "UInt8.mix.msbAt  == -1")
test.eq(UInt.max.msbAt, sizeof(UInt)*8-1, "UInt(\(UInt.max)).msbAt == \(sizeof(UInt)*8-1)")
test.eq(UInt.min.msbAt,     -1, "UInt(\(UInt.min)).msbAt == -1")
let uint128max = BigUInt(1)<<128 - 1
let uint128min = UInt.min
// POInt#msbAt
test.eq(uint128max.msbAt,  127, "BigUInt(uint128max).msbAt == 127")
test.eq(uint128min.msbAt,   -1, "BigUInt(uint128max).msbAt ==  -1")
test.eq(Int64.max.msbAt,    62, "Int64.max.msbAt == 62")
test.eq(Int64.min.msbAt,    63, "Int64.min.msbAt == 63")
test.eq(Int32.max.msbAt,    30, "Int32.max.msbAt == 30")
test.eq(Int32.min.msbAt,    31, "Int32.min.msbAt == 31")
test.eq(Int16.max.msbAt,    14, "Int16.max.msbAt == 14")
test.eq(Int16.min.msbAt,    15, "Int16.min.msbAt == 15")
test.eq(Int8.max.msbAt,      6, "Int8.max.msbAt  ==  6")
test.eq(Int8.min.msbAt,      7, "Int8.min.msbAt  ==  7")
test.eq(Int.max.msbAt, sizeof(UInt)*8-2, "Int(\(Int.max)).msbAt == \(sizeof(UInt)*8-2)")
test.eq(Int.min.msbAt, sizeof(UInt)*8-1, "Int(\(Int.min)).msbAt == \(sizeof(UInt)*8-1)")
let int128max = BigInt(uint128max) >> 1
let int128min = -BigInt(uint128max)
test.eq(int128max.msbAt,   126, "BigInt(int128max).msbAt == 126")
test.eq(int128min.msbAt,   127, "BigInt(int128mix).msbAt == 127")
// Protocol Extension
func fact<T:POInteger>(n:T)->T {
    return n < 2 ? 1 : (2...n).reduce(1, combine:*)
}
let ufact20 = 2432902008176640000 as UInt
let ufact42 = BigUInt("1405006117752879898543142606244511569936384000000000")
test.eq(fact(20 as UInt),       ufact20, "20! as UInt    == \(ufact20)")
test.eq(fact(42 as BigUInt),    ufact42, "42! as BigUInt == \(ufact42)")
let sfact20 = 0x21C3677C82B40000 as Int
let sfact42 = BigInt("0x3C1581D491B28F523C23ABDF35B689C908000000000")
test.eq(fact(20 as Int),    sfact20, "20! as Int    == \(sfact20)")
test.eq(fact(42 as BigInt), sfact42, "42! as BigInt == \(sfact42)")
// BigInt: literal convertibility
test.eq(BigInt(+42 as Int), +BigInt(42), "BigInt(+42 as Int) == +BigInt(42)")
test.eq(BigInt(-42 as Int), -BigInt(42), "BigInt(-42 as Int) == -BigInt(42)")
test.eq(9223372036854775807 as BigInt, BigInt(Int.max), "BigInt is integerLiteralConvertible")
test.eq("0xfedcba98765432100123456789ABCDEF" as BigInt,
    BigInt("fedcba98765432100123456789ABCDEF", radix:16), "BigInt is stringLiteralConvertible")
// BigInt: signed operations
test.eq(+BigInt(2) + +BigInt(1), +BigInt(3), "+2 + +1 == +3")
test.eq(-BigInt(2) + +BigInt(1), -BigInt(1), "-2 + +1 == -1")
test.eq(+BigInt(2) + -BigInt(1), +BigInt(1), "+2 + -1 == +1")
test.eq(-BigInt(2) + -BigInt(1), -BigInt(3), "-2 + -1 == -3")
test.eq(+BigInt(2) - +BigInt(1), +BigInt(1), "+2 - +1 == +1")
test.eq(-BigInt(2) - +BigInt(1), -BigInt(3), "-2 - +1 == -3")
test.eq(+BigInt(2) - -BigInt(1), +BigInt(3), "+2 - -1 == +3")
test.eq(-BigInt(2) - +BigInt(1), -BigInt(3), "-2 - -1 == -1")
test.eq(+BigInt(1) * +BigInt(1), +BigInt(1), "+1 * +1 == +1")
test.eq(-BigInt(1) * +BigInt(1), -BigInt(1), "-1 * +1 == -1")
test.eq(+BigInt(1) * -BigInt(1), -BigInt(1), "+1 * -1 == -1")
test.eq(-BigInt(1) * -BigInt(1), +BigInt(1), "-1 * -1 == +1")
test.eq(+BigInt(3) / +BigInt(2), +BigInt(1), "+3 / +1 == +1")
test.eq(-BigInt(3) / +BigInt(2), -BigInt(1), "-3 / +1 == -1")
test.eq(+BigInt(3) / -BigInt(2), -BigInt(1), "+3 / -1 == -1")
test.eq(-BigInt(3) / -BigInt(2), +BigInt(1), "-3 / -1 == +1")
test.eq(+BigInt(3) % +BigInt(2), +BigInt(1), "+3 % +1 == +1")
test.eq(-BigInt(3) % +BigInt(2), -BigInt(1), "-3 % +1 == -1")
test.eq(+BigInt(3) % -BigInt(2), +BigInt(1), "+3 % -2 == +1")
test.eq(-BigInt(3) % -BigInt(2), -BigInt(1), "-3 % -2 == -1")
// BigInt / BigInt test
for i in 1...42 {
    let bi = i.asBigInt
    test.eq(fact(bi) / fact(bi - 1), bi,    "BigInt: \(bi)!/\(bi-1)! == \(bi)")
    if i > 20 { continue }
    test.eq(fact(i) / fact(i - 1),  i,      "Int:    \(bi)!/\(bi-1)! == \(bi)")
}
// Complex
({
    test.eq(1.0-1.0.i, Complex(1.0,-1.0),           "1.0-1.0.i == Complex(1.0,-1.0)")
    test.ok(1.0+0.0.i==1.0,                         "1.0+0.0.i == 1")
    test.ok(    0.0.i==0.0,                         "    0.0.i == 0")
    test.eq(Complex(),     0+0.i,                   "Complex(), 0+0.i")
    test.eq(Complex(), 0.0+0.0.i,                   "Complex(), 0.0+0.0.i")
    test.eq("\(Complex(0.0,+0.0))", "(0.0+0.0.i)",  "0.0+0.0.i")
    test.eq("\(Complex(0.0,-0.0))", "(0.0-0.0.i)",  "0.0-0.0.i")
    var z0 = Complex(abs:10.0, arg:Double.atan2(3.0,4.0))
    test.eq(z0, 8.0+6.0.i      , "Complex(abs:10, arg:atan2(3,4)) == 8.0+6.0.i")
    test.eq(z0 - z0, 0.0+0.0.i , "z - z = 0+0.i")
    test.eq(z0 + z0, z0 * 2    , "z + z = z0*2")
    var z1 = z0; z1 *= z1;
    test.eq(z1, z0*z0  , "var z1=z0; z1*=z1; z1==z0*z0")
    test.eq(z1.abs, z0.abs ** 2  , "z1.abs == z0.abs * z0.abs")
    test.eq(z1.arg, z0.arg *  2  , "z1.arg == z0.abs + z0.arg")
    z1 /= z0;
    test.eq(z1, z0, "z1 /= z0; z1==z0")
})()
({
    let z0 = 0.0 + 0.0.i, zm0 = -z0
    let z1 = 1.0 + 0.0.i, z42_195 = 42.0 + 0.195.i
    test.ok(z0  ** -1.0 == +1.0/0.0, "\(z0 ) ** -1.0 == \(+1.0/0.0)")
    test.ok(zm0 ** -1.0 == -1.0/0.0, "\(zm0) ** -1.0 == \(-1.0/0.0)")
    test.ok(z0  ** -2.0 == +1.0/0.0, "\(z0 ) ** -2.0 == \(+1.0/0.0)")
    test.ok(zm0 ** -2.0 == +1.0/0.0, "\(zm0) ** -2.0 == \(+1.0/0.0)")
    test.eq(z1 ** z42_195,   z1, "\(z1) ** y  == \(z1) // for any y")
    test.eq(z42_195 ** z0,   z1, "x ** \(z0 ) == \(z1) // for any x")
    test.eq(z42_195 ** zm0,  z1, "x ** \(zm0) == \(z1) // for any x")
})()
({
    typealias R=Double
    typealias C=Complex<R>
    test.eq(C.log10(100.i).re, 2.0,             "log10(100.i).re == 2.0")
    test.eq(C.log10(100.i).im, C.log10(1.0.i).im, "log10(100.i).im == log10(1.i).im")
    test.eq(2.0 * 3.0 ** 4.0, 162.0,            "2.0*3.0**4.0 == 2.0 * (3.0 ** 4.0)")
    test.eq((R.E+0.0.i)**R.PI.i, C.exp(R.PI.i), "exp(z) == e ** z")
    test.eq(C.sqrt(-1.0), 1.0.i,                "sqrt(-1) == i")
    test.eq(C.sqrt(2.0.i),    1.0+1.0.i,        "sqrt(2i) == 1+i")
    test.eq(2.0.i **  2.5, -4.0-4.0.i,          "z **  2.5  == z*z*sqrt(z)")
    test.eq(2.0.i **  2.0, -4.0+0.0.i,          "z **  2    == z*z")
    test.eq(2.0.i **  1.5, -2.0+2.0.i,          "z **  1.5  == z*sqrt(z)")
    test.eq(2.0.i **  1.0,  2.0.i,              "z **  1    == z")
    test.eq(2.0.i **  0.5,  1.0+1.0.i,          "z **  0.5  == sqrt(z)")
    test.eq(2.0.i **  0.0,  1.0+0.0.i,          "z **  0    == 1")
    test.eq(2.0.i ** -0.5,  0.5-0.5.i,          "z ** -0.5  == 1/sqrt(z)")
    test.eq(2.0.i ** -1.0, -0.5.i,              "z ** -1    == 1/z")
    test.eq(2.0.i ** -1.5, (-1.0-1.0.i)/4.0,    "z ** -1.5  == 1/(z*sqrt(z))")
    test.eq(2.0.i ** -2.0, -0.25+0.0.i,         "z ** -2    == 1/(z*z)")
    test.eq(2.0.i ** -2.5, (-1.0+1.0.i)/8.0,    "z ** -2.5  == 1/(z*z*sqrt(z))")
    let r = 0.5, z = C.sqrt(-1.0.i)
    var dict = [0+0.i:"origin"]
    test.ok(dict[0+0.i] == "origin", "Complex as a dictionary key")
})()
// Rational
test.eq("\(+2.over(4))", "(1/2)",  "\"\\(+2.over(4))\" == \"(1/2)\"")
test.eq("\(-2.over(4))", "-(1/2)", "\"\\(-2.over(4))\" == \"-(1/2)\"")
test.eq("\(2.over(4)+2.over(4).i)", "((1/2)+(1/2).i)",
    "\"\\(2.over(4)+2.over(4).i)\" == \"((1/2)+(1/2).i)\"")
test.eq("\(2.over(4)-2.over(4).i)", "((1/2)-(1/2).i)",
    "\"\\(2.over(4)-2.over(4).i)\" == \"((1/2)+(1/2).i)\"")
test.eq(+2.over(+4), +1.over(2), "+2/+4 == +1/2")
test.eq(+2.over(-4), -1.over(2), "-2/+4 == -1/2")
test.eq(-2.over(+4), -1.over(2), "+2/-4 == -1/2")
test.eq(-2.over(-4), +1.over(2), "-2/-4 == +1/2")
test.ok((+42.over(0)).isInfinite, "\(+42.over(0)) is infinite")
test.ok((-42.over(0)).isInfinite, "\(-42.over(0)) is infinite")
test.ok((0.over(0)).isNaN, "\(0.over(0)) is NaN")
test.ne(0.over(0), 0.over(0), "NaN != NaN")

print((-14).over(6).asMixed)

test.done()


