//
//  main.swift
//  pons
//
//  Created by Dan Kogai on 2/4/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

let test = TAP()

test.eq(Bool.xor(true,   true), false,  "xor(true, true)   == false")
test.eq(Bool.xor(true,  false), true,   "xor(true, false)  == true")
test.eq(Bool.xor(false,  true), true,   "xor(false, false) == true")
test.eq(Bool.xor(false, false), false,  "xor(false, false) == false")

test.eq(UInt64.max.msbAt, 63,   "UInt64.max.msbAt == 63")
test.eq(UInt64.min.msbAt, -1,   "UInt64.min.msbAt == -1")
test.eq(UInt32.max.msbAt, 31,   "UInt32.max.msbAt == 31")
test.eq(UInt32.min.msbAt, -1,   "UInt32.min.msbAt == -1")
test.eq(UInt16.max.msbAt, 15,   "UInt16.max.msbAt == 15")
test.eq(UInt16.min.msbAt, -1,   "UInt16.mix.msbAt == -1")
test.eq(UInt8.max.msbAt,   7,   "UInt8.max.msbAt  ==  7")
test.eq(UInt8.min.msbAt,  -1,   "UInt8.mix.msbAt  == -1")
test.eq(UInt.max.msbAt, sizeof(UInt)*8-1, "UInt(\(UInt.max)).msbAt == \(sizeof(UInt)*8-1)")
test.eq(UInt.min.msbAt,   -1,   "UInt(\(UInt.min)).msbAt == -1")
let uint128max = BigUInt(1)<<128 - 1
test.eq(uint128max.msbAt, 127,  "BigUInt(\"\(uint128max.debugDescription)\").msbAt == 127")
test.eq(Int64.max.msbAt,  62,   "Int64.max.msbAt == 62")
test.eq(Int64.min.msbAt,  63,   "Int64.min.msbAt == 63")
test.eq(Int32.max.msbAt,  30,   "Int32.max.msbAt == 30")
test.eq(Int32.min.msbAt,  31,   "Int32.min.msbAt == 31")
test.eq(Int16.max.msbAt,  14,   "Int16.max.msbAt == 14")
test.eq(Int16.min.msbAt,  15,   "Int16.min.msbAt == 15")
test.eq(Int8.max.msbAt,    6,   "Int8.max.msbAt  ==  6")
test.eq(Int8.min.msbAt,    7,   "Int8.min.msbAt  ==  7")
test.eq(Int.max.msbAt, sizeof(UInt)*8-2, "Int(\(Int.max)).msbAt == \(sizeof(UInt)*8-2)")
test.eq(Int.min.msbAt, sizeof(UInt)*8-1, "Int(\(Int.min)).msbAt == \(sizeof(UInt)*8-1)")
let int128max = BigInt(uint128max) >> 1
let int128min = -BigInt(uint128max)
test.eq(int128max.msbAt, 126,  "BigInt(\"\(int128max.debugDescription)\").msbAt == 126")
test.eq(int128min.msbAt, 127,  "BigInt(\"\(int128min.debugDescription)\").msbAt == 127")
test.done()
