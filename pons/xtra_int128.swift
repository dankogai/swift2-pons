//
//  xtra_int128.swift
//  pons
//
//  Created by Dan Kogai on 2/26/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

public struct Int128 : POInt {
    public typealias UIntType = UInt128
    public static let precision = 127
    public static let allZeros = Int128(0)
    public typealias DigitType = BigUInt.DigitType
    public var value:(DigitType, DigitType, DigitType, DigitType) = (0, 0, 0, 0)
    public init(_ d0:DigitType, _ d1:DigitType, _ d2:DigitType, _ d3:DigitType) {
        self.value = (d0, d1, d2, d3)
    }
    public init(_ i128:Int128) {
        self.value = i128.value
    }
    public init(_ u128:UInt128) {
        self.value = u128.value
    }
    public init(_ u:UIntMax) {
        value.0 = DigitType(u & 0xffff_ffff)
        value.1 = DigitType(u >> 32)
    }
    public init(_ u:UInt) {
        self.init(u.toUIntMax())
    }
    public init(_  i:Int) {
        let u = unsafeBitCast(i, UIntMax.self)
        let p =  DigitType(i < 0 ? 0xffff_ffff : 0)
        self.init(DigitType(u & 0xffff_ffff), DigitType(u >> 32), p, p)
    }
    public init(_ bi:BigInt) {
        let d  = bi.unsignedValue.digits
        switch d.count {
        case 1: value = (d[0],    0,    0,    0)
        case 2: value = (d[0], d[1],    0,    0)
        case 3: value = (d[0], d[1], d[2],    0)
        default:value = (d[0], d[1], d[2], d[3])
        }
        if bi.isSignMinus {
            self = -self
        }
    }
    public var inBigInt:BigInt {
        let a = self.isSignMinus ? -self : self
        let bu = BigUInt(rawValue: [a.value.0, a.value.1, a.value.2, a.value.3])
        return BigInt(unsignedValue:bu, isSignMinus: self.isSignMinus)
    }
    public var asBigInt:BigInt? {
        return self.inBigInt
    }
    public var isSignMinus:Bool {
        return value.3 & 0x8000_0000 != 0
    }
    public func toIntMax()->IntMax {
        if value.3 & 0x8000_0000 != 0 {
            if value.3 != 0xffff_ffff && value.2 != 0xffff_ffff {
                fatalError("\(self.value) overflows")
            }
        } else {
            if value.3 != 0 && value.2 != 0 {
                fatalError("\(self.value) overflows")
            }
        }
        return unsafeBitCast(UIntMax(value.1)<<32 | UIntMax(value.0), IntMax.self)
    }
    public var msbAt:Int {
        return value.3 != 0 ? 96 + value.3.msbAt
            :  value.2 != 0 ? 64 + value.2.msbAt
            :  value.1 != 0 ? 32 + value.1.msbAt
            :                      value.0.msbAt
    }
    public var asUnsigned:UIntType? {
        return self < 0 ? nil : UIntType(self)
    }
    public var description:String {
        return self.inBigInt.description
    }
    public var debugDescription:String {
        return self.inBigInt.debugDescription
    }
    private static let minInBigInt = -(BigInt(1)<<127)
    public static let min = Int128(minInBigInt)
    private static let maxInBigInt = +(BigInt(1)<<127 - BigInt(1))
    public static let max = Int128(maxInBigInt)
    public static func addWithOverflow(lhs:Int128, _ rhs:Int128)->(Int128, overflow:Bool) {
        let (bi, _) = BigInt.addWithOverflow(lhs.inBigInt, rhs.inBigInt)
        return (Int128(bi), bi < minInBigInt || maxInBigInt < bi)
    }
    public static func subtractWithOverflow(lhs:Int128, _ rhs:Int128)->(Int128, overflow:Bool) {
        let (bi, _) = BigInt.subtractWithOverflow(lhs.inBigInt, rhs.inBigInt)
        return (Int128(bi), bi < minInBigInt || maxInBigInt < bi)
    }
    public static func multiplyWithOverflow(lhs:Int128, _ rhs:Int128)->(Int128, overflow:Bool) {
        let (bi, _) = BigInt.multiplyWithOverflow(lhs.inBigInt, rhs.inBigInt)
        return (Int128(bi), bi < minInBigInt || maxInBigInt < bi)
    }
    public static func divmod(lhs:Int128, _ rhs:Int128)->(Int128, Int128) {
        let (q, r) = BigInt.divmod(lhs.inBigInt, rhs.inBigInt)
        return (Int128(q), Int128(r))
    }
    public static func divideWithOverflow(lhs:Int128, _ rhs:Int128)->(Int128, overflow:Bool) {
        return (divmod(lhs, rhs).0, false)
    }
    public static func remainderWithOverflow(lhs:Int128, _ rhs:Int128)->(Int128, overflow:Bool) {
        return (divmod(lhs, rhs).1, false)
    }
}
public prefix func -(i:Int128)->Int128 {
    var r = ~i
    var carry = true
    if carry {
        if r.value.0 == 0xffff_ffff { r.value.0 = 0 }
        else { r.value.0 += 1 ; carry = false }
    }
    if carry {
        if r.value.1 == 0xffff_ffff { r.value.1 = 0 }
        else { r.value.1 += 1 ; carry = false }
    }
    if carry {
        if r.value.2 == 0xffff_ffff { r.value.2 = 0 }
        else { r.value.2 += 1 ; carry = false }
    }
    if carry { r.value.3 += 1 }
    return r
}
public func ==(lhs:Int128, rhs:Int128)->Bool {
    let lv = lhs.value
    let rv = rhs.value
    return lv.0 == rv.0 && lv.1 == rv.1 && lv.2 == rv.2 && lv.3 == rv.3
}
public func <(lhs:Int128, rhs:Int128)->Bool {
    return Int128.subtractWithOverflow(lhs, rhs).0.isSignMinus
}
public prefix func ~(i128:Int128)->Int128 {
    return Int128(~i128.value.0, ~i128.value.1, ~i128.value.2, ~i128.value.3)
}
public func &(lhs:Int128, rhs:Int128)->Int128 {
    return Int128(
        lhs.value.0 & rhs.value.0,
        lhs.value.1 & rhs.value.1,
        lhs.value.2 & rhs.value.2,
        lhs.value.3 & rhs.value.3
    )
}
public func |(lhs:Int128, rhs:Int128)->Int128 {
    return Int128(
        lhs.value.0 | rhs.value.0,
        lhs.value.1 | rhs.value.1,
        lhs.value.2 | rhs.value.2,
        lhs.value.3 | rhs.value.3
    )
}
public func ^(lhs:Int128, rhs:Int128)->Int128 {
    return Int128(
        lhs.value.0 ^ rhs.value.0,
        lhs.value.1 ^ rhs.value.1,
        lhs.value.2 ^ rhs.value.2,
        lhs.value.3 ^ rhs.value.3
    )
}
public func <<(lhs:Int128, rhs:Int128)->Int128 {
    return Int128( lhs.inBigInt << rhs.inBigInt )
}
public func >>(lhs:Int128, rhs:Int128)->Int128 {
    return Int128( lhs.inBigInt >> rhs.inBigInt )
}