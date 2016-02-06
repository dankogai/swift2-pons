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

var dict = [BigInt(42):42]

var x = Int.power(3, 3, op:*)

test.done()
