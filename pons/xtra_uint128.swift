//
//  xtra_uint128.swift
//  test
//
//  Created by Dan Kogai on 2/25/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

public struct UInt128 : POUInt {
    public typealias IntType = BigInt
    public static let precision = 128
    public static let allZeros = UInt128(0)
    public typealias DigitType = BigUInt.DigitType
    public var value:(DigitType, DigitType, DigitType, DigitType) = (0, 0, 0, 0)
    public init(_ d0:DigitType, _ d1:DigitType, _ d2:DigitType, _ d3:DigitType) {
        self.value = (d0, d1, d2, d3)
    }
    public init(_ u128:UInt128) {
        self.value = u128.value
    }
    public init(_ bu:BigUInt) {
        let d  = bu.digits
        switch d.count {
        case 1: value = (d[0],    0,    0,    0)
        case 2: value = (d[0], d[1],    0,    0)
        case 3: value = (d[0], d[1], d[2],    0)
        default:value = (d[0], d[1], d[2], d[3])
        }
    }
    public init(_ u:UIntMax) {
        value.0 = DigitType(u & 0xffff_ffff)
        value.1 = DigitType(u >> 32)
    }
    public init(_ u:UInt) {
        self.init(BigUInt(u))
    }
    public init(_ i:Int) {
        if i < 0 {
            fatalError("\(i) < 0")
        }
        self.init(BigUInt(i.abs))
    }
    public var inBigUInt:BigUInt {
        return BigUInt(rawValue:[value.0, value.1, value.2, value.3])
    }
    public var asBigUInt:BigUInt? {
        return self.inBigUInt
    }
    public func toUIntMax()->UIntMax {
        if value.2 != 0 || value.3 != 0 {
            fatalError("\(self) > UIntMax.max = \(UIntMax.max)")
        }
        return UIntMax(value.1)<<32 | UIntMax(value.0)
    }
    public func toIntMax()->IntMax {
        return IntMax(self.toUIntMax())
    }
    public var asUInt32:UInt32? {
        if value.1 != 0 || value.2 != 0 || value.3 != 0 {
            return nil
        }
        return value.0
    }
    public var msbAt:Int {
        return value.3 != 0 ? 96 + value.3.msbAt
            :  value.2 != 0 ? 64 + value.2.msbAt
            :  value.1 != 0 ? 32 + value.1.msbAt
            :                      value.0.msbAt
    }
    public var asSigned:IntType? {
        return self.inBigUInt.asSigned
    }
    public static let min = UInt128(0)
    public static let max = UInt128(BigUInt(1)<<128-1)
    public static func divideWithOverflow(lhs:UInt128, _ rhs:UInt128)->(UInt128, overflow:Bool) {
        return (divmod(lhs, rhs).0, false)
    }
    public static func remainderWithOverflow(lhs:UInt128, _ rhs:UInt128)->(UInt128, overflow:Bool) {
        return (divmod(lhs, rhs).1, false)
    }
}
public func ==(lhs:UInt128, rhs:UInt128)->Bool {
    let lv = lhs.value
    let rv = rhs.value
    return lv.0 == rv.0 && lv.1 == rv.1 && lv.2 == rv.2 && lv.3 == rv.3
}
public func <(lhs:UInt128, rhs:UInt128)->Bool {
    return UInt128.subtractWithOverflow(lhs, rhs).1
}
public prefix func ~(u128:UInt128)->UInt128 {
    return UInt128(~u128.value.0, ~u128.value.1, ~u128.value.2, ~u128.value.3)
}
public func &(lhs:UInt128, rhs:UInt128)->UInt128 {
    return UInt128(
        lhs.value.0 & rhs.value.0,
        lhs.value.1 & rhs.value.1,
        lhs.value.2 & rhs.value.2,
        lhs.value.3 & rhs.value.3
    )
}
public func |(lhs:UInt128, rhs:UInt128)->UInt128 {
    return UInt128(
        lhs.value.0 | rhs.value.0,
        lhs.value.1 | rhs.value.1,
        lhs.value.2 | rhs.value.2,
        lhs.value.3 | rhs.value.3
    )
}
public func ^(lhs:UInt128, rhs:UInt128)->UInt128 {
    return UInt128(
        lhs.value.0 | rhs.value.0,
        lhs.value.1 | rhs.value.1,
        lhs.value.2 | rhs.value.2,
        lhs.value.3 | rhs.value.3
    )
}
#if !os(OSX)    // slow but steady BigInt arithmetics
public extension UInt128 {
    public static func addWithOverflow(lhs:UInt128, _ rhs:UInt128)->(UInt128, overflow:Bool) {
        let (bu, overflow) = BigUInt.addWithOverflow(lhs.inBigUInt, rhs.inBigUInt)
        return (UInt128(bu), overflow || bu.digits.count > 4)
    }
    public static func subtractWithOverflow(lhs:UInt128, _ rhs:UInt128)->(UInt128, overflow:Bool) {
        let (bu, overflow) = BigUInt.subtractWithOverflow(lhs.inBigUInt, rhs.inBigUInt)
        return (UInt128(bu), overflow || bu.digits.count > 4)
    }
    public static func multiplyWithOverflow(lhs:UInt128, _ rhs:UInt128)->(UInt128, overflow:Bool) {
        let (bu, overflow) = BigUInt.multiplyWithOverflow(lhs.inBigUInt, rhs.inBigUInt)
        return (UInt128(bu), overflow || bu.digits.count > 4)
    }
    public static func divmod(lhs:UInt128, _ rhs:UInt128)->(UInt128, UInt128) {
        let (q, r) = BigUInt.divmod(lhs.inBigUInt, rhs.inBigUInt)
        return (UInt128(q), UInt128(r))
    }
}
public func <<(lhs:UInt128, rhs:UInt128)->UInt128 {
    return UInt128( lhs.inBigUInt << rhs.inBigUInt )
}
public func >>(lhs:UInt128, rhs:UInt128)->UInt128 {
    return UInt128( lhs.inBigUInt >> rhs.inBigUInt )
}
#else   // fast arithmetics via Accelerate.  OS X only
import Accelerate
public extension UInt128 {
    public static func addWithOverflow(lhs:UInt128, _ rhs:UInt128)->(UInt128, overflow:Bool) {
        var a = unsafeBitCast((lhs, vU128()), vU256.self)
        var b = unsafeBitCast((rhs, vU128()), vU256.self)
        var ab = vU256()
        vU256Add(&a, &b, &ab)
        let (r, o) =  unsafeBitCast(ab, (UInt128, UInt128).self)
        return (r, o != 0)
    }
    public static func subtractWithOverflow(lhs:UInt128, _ rhs:UInt128)->(UInt128, overflow:Bool) {
        var a = unsafeBitCast((lhs, vU128()), vU256.self)
        var b = unsafeBitCast((rhs, vU128()), vU256.self)
        var ab = vU256()
        vU256Sub(&a, &b, &ab)
        let (r, o) =  unsafeBitCast(ab, (UInt128, UInt128).self)
        return (r, o != 0)
    }
    public static func multiplyWithOverflow(lhs:UInt128, _ rhs:UInt128)->(UInt128, overflow:Bool) {
        var a = unsafeBitCast(lhs, vU128.self)
        var b = unsafeBitCast(rhs, vU128.self)
        var ab = vU256()
        vU128FullMultiply(&a, &b, &ab)
        let (r, o) =  unsafeBitCast(ab, (UInt128, UInt128).self)
        return (r, o != 0)
    }
    public static func divmod(lhs:UInt128, _ rhs:UInt128)->(UInt128, UInt128) {
        var a = unsafeBitCast((lhs, vU128()), vU256.self)
        var b = unsafeBitCast((rhs, vU128()), vU256.self)
        var (q, r) = (vU256(), vU256())
        vU256Divide(&a, &b, &q, &r)
        return (unsafeBitCast(q, (UInt128, UInt128).self).0, unsafeBitCast(r, (UInt128, UInt128).self).0)
    }
}
public func <<(lhs:UInt128, rhs:UInt128)->UInt128 {
    var a = unsafeBitCast((lhs, vU128()), vU256.self)
    var r = vU256()
    vLL256Shift(&a, rhs.asUInt32!, &r)
    return unsafeBitCast(r, (UInt128, UInt128).self).0
}
public func >>(lhs:UInt128, rhs:UInt128)->UInt128 {
    var a = unsafeBitCast((lhs, vU128()), vU256.self)
    var r = vU256()
    vLR256Shift(&a, rhs.asUInt32!, &r)
    return unsafeBitCast(r, (UInt128, UInt128).self).0
}
#endif
