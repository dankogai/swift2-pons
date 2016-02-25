//
//  xtra_uint256.swift
//  test
//
//  Created by Dan Kogai on 2/25/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

public struct UInt256 : POUInt {
    public typealias IntType = BigInt
    public static let precision = 256
    public static let allZeros = UInt256(0)
    public typealias DigitType = BigUInt.DigitType
    public var value:
        (DigitType, DigitType, DigitType, DigitType,DigitType, DigitType, DigitType, DigitType)
        = (0, 0, 0, 0, 0, 0, 0, 0)
    public init(
        _ d0:DigitType, _ d1:DigitType, _ d2:DigitType, _ d3:DigitType,
        _ d4:DigitType, _ d5:DigitType, _ d6:DigitType, _ d7:DigitType
        ) {
        self.value = (d0, d1, d2, d3, d4, d5, d6, d7)
    }
    public init(_ u256:UInt256) {
        self.value = u256.value
    }
    public init(_ bu:BigUInt) {
        let d  = bu.digits
        switch d.count {
        case 1: value = (d[0],    0,    0,    0,    0,    0,    0,    0)
        case 2: value = (d[0], d[1],    0,    0,    0,    0,    0,    0)
        case 3: value = (d[0], d[1], d[2],    0,    0,    0,    0,    0)
        case 4: value = (d[0], d[1], d[2], d[3],    0,    0,    0,    0)
        case 5: value = (d[0], d[1], d[2], d[3], d[4],    0,    0,    0)
        case 6: value = (d[0], d[1], d[2], d[3], d[4], d[5],    0,    0)
        case 7: value = (d[0], d[1], d[2], d[3], d[4], d[5], d[6],    0)
        default:value = (d[0], d[1], d[2], d[3], d[4], d[5], d[6], d[7])
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
    public init(_ u128:UInt128) {
        (value.0, value.1, value.2, value.3) = u128.value
    }
    public var inBigUInt:BigUInt {
        return BigUInt(
            rawValue:[value.0, value.1, value.2, value.3, value.4, value.5, value.6, value.7]
        )
    }
    public var asBigUInt:BigUInt? {
        return self.inBigUInt
    }
    public func toUIntMax()->UIntMax {
        if value.2 != 0 || value.3 != 0 || value.4 != 0 || value.5 != 0 || value.6 != 0 || value.7 != 0 {
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
        return value.7 != 0 ? 224 + value.7.msbAt
            :  value.6 != 0 ? 192 + value.6.msbAt
            :  value.5 != 0 ? 160 + value.5.msbAt
            :  value.4 != 0 ? 128 + value.4.msbAt
            :  value.3 != 0 ?  96 + value.3.msbAt
            :  value.2 != 0 ?  64 + value.2.msbAt
            :  value.1 != 0 ?  32 + value.1.msbAt
            :                       value.0.msbAt
    }
    public var asSigned:IntType? {
        return self.inBigUInt.asSigned
    }
    public static let min = UInt256(0)
    public static let max = UInt256(BigUInt(1)<<256-1)
    public static func divideWithOverflow(lhs:UInt256, _ rhs:UInt256)->(UInt256, overflow:Bool) {
        return (divmod(lhs, rhs).0, false)
    }
    public static func remainderWithOverflow(lhs:UInt256, _ rhs:UInt256)->(UInt256, overflow:Bool) {
        return (divmod(lhs, rhs).1, false)
    }
}
public func ==(lhs:UInt256, rhs:UInt256)->Bool {
    let lv = lhs.value
    let rv = rhs.value
    return lv.0 == rv.0 && lv.1 == rv.1 && lv.2 == rv.2 && lv.3 == rv.3
        && lv.4 == rv.4 && lv.5 == rv.5 && lv.6 == rv.6 && lv.7 == rv.7
}
public func <(lhs:UInt256, rhs:UInt256)->Bool {
    return UInt256.subtractWithOverflow(lhs, rhs).1
}
public prefix func ~(u128:UInt256)->UInt256 {
    return UInt256(
        ~u128.value.0, ~u128.value.1, ~u128.value.2, ~u128.value.3,
        ~u128.value.4, ~u128.value.5, ~u128.value.6, ~u128.value.7
    )
}
public func &(lhs:UInt256, rhs:UInt256)->UInt256 {
    return UInt256(
        lhs.value.0 & rhs.value.0,
        lhs.value.1 & rhs.value.1,
        lhs.value.2 & rhs.value.2,
        lhs.value.3 & rhs.value.3,
        lhs.value.4 & rhs.value.4,
        lhs.value.5 & rhs.value.5,
        lhs.value.6 & rhs.value.6,
        lhs.value.7 & rhs.value.7
    )
}
public func |(lhs:UInt256, rhs:UInt256)->UInt256 {
    return UInt256(
        lhs.value.0 | rhs.value.0,
        lhs.value.1 | rhs.value.1,
        lhs.value.2 | rhs.value.2,
        lhs.value.3 | rhs.value.3,
        lhs.value.4 | rhs.value.4,
        lhs.value.5 | rhs.value.5,
        lhs.value.6 | rhs.value.6,
        lhs.value.7 | rhs.value.7
    )
}
public func ^(lhs:UInt256, rhs:UInt256)->UInt256 {
    return UInt256(
        lhs.value.0 ^ rhs.value.0,
        lhs.value.1 ^ rhs.value.1,
        lhs.value.2 ^ rhs.value.2,
        lhs.value.3 ^ rhs.value.3,
        lhs.value.4 ^ rhs.value.4,
        lhs.value.5 ^ rhs.value.5,
        lhs.value.6 ^ rhs.value.6,
        lhs.value.7 ^ rhs.value.7
    )
}
#if !os(OSX)    // slow but steady BigInt arithmetics
public extension UInt256 {
    public static func addWithOverflow(lhs:UInt256, _ rhs:UInt256)->(UInt256, overflow:Bool) {
        let (bu, overflow) = BigUInt.addWithOverflow(lhs.inBigUInt, rhs.inBigUInt)
        return (UInt256(bu), overflow || bu.digits.count > 8)
    }
    public static func subtractWithOverflow(lhs:UInt256, _ rhs:UInt256)->(UInt256, overflow:Bool) {
        let (bu, overflow) = BigUInt.subtractWithOverflow(lhs.inBigUInt, rhs.inBigUInt)
        return (UInt256(bu), overflow || bu.digits.count > 8)
    }
    public static func multiplyWithOverflow(lhs:UInt256, _ rhs:UInt256)->(UInt256, overflow:Bool) {
        let (bu, overflow) = BigUInt.multiplyWithOverflow(lhs.inBigUInt, rhs.inBigUInt)
        return (UInt256(bu), overflow || bu.digits.count > 8)
    }
    public static func divmod(lhs:UInt256, _ rhs:UInt256)->(UInt256, UInt256) {
        let (q, r) = BigUInt.divmod(lhs.inBigUInt, rhs.inBigUInt)
        return (UInt256(q), UInt256(r))
    }
}
public func <<(lhs:UInt256, rhs:UInt256)->UInt256 {
    return UInt256( lhs.inBigUInt << rhs.inBigUInt )
}
public func >>(lhs:UInt256, rhs:UInt256)->UInt256 {
    return UInt256( lhs.inBigUInt >> rhs.inBigUInt )
}
#else   // fast arithmetics via Accelerate.  OS X only
    import Accelerate
public extension UInt256 {
    public static func addWithOverflow(lhs:UInt256, _ rhs:UInt256)->(UInt256, overflow:Bool) {
        var a = unsafeBitCast((lhs, vU256()), vU512.self)
        var b = unsafeBitCast((rhs, vU256()), vU512.self)
        var ab = vU512()
        vU512Add(&a, &b, &ab)
        let (r, o) =  unsafeBitCast(ab, (UInt256, UInt256).self)
        return (r, o != 0)
    }
    public static func subtractWithOverflow(lhs:UInt256, _ rhs:UInt256)->(UInt256, overflow:Bool) {
        var a = unsafeBitCast((lhs, vU256()), vU512.self)
        var b = unsafeBitCast((rhs, vU256()), vU512.self)
        var ab = vU512()
        vU512Sub(&a, &b, &ab)
        let (r, o) =  unsafeBitCast(ab, (UInt256, UInt256).self)
        return (r, o != 0)
    }
    public static func multiplyWithOverflow(lhs:UInt256, _ rhs:UInt256)->(UInt256, overflow:Bool) {
        var a = unsafeBitCast(lhs, vU256.self)
        var b = unsafeBitCast(rhs, vU256.self)
        var ab = vU512()
        vU256FullMultiply(&a, &b, &ab)
        let (r, o) =  unsafeBitCast(ab, (UInt256, UInt256).self)
        return (r, o != 0)
    }
    public static func divmod(lhs:UInt256, _ rhs:UInt256)->(UInt256, UInt256) {
        var a = unsafeBitCast((lhs, vU256()), vU512.self)
        var b = unsafeBitCast((rhs, vU256()), vU512.self)
        var (q, r) = (vU512(), vU512())
        vU512Divide(&a, &b, &q, &r)
        return (unsafeBitCast(q, (UInt256, UInt256).self).0, unsafeBitCast(r, (UInt256, UInt256).self).0)
    }
}
public func <<(lhs:UInt256, rhs:UInt256)->UInt256 {
    var a = unsafeBitCast((lhs, vU256()), vU512.self)
    var r = vU512()
    vLL512Shift(&a, rhs.asUInt32!, &r)
    return unsafeBitCast(r, (UInt256, UInt256).self).0
}
public func >>(lhs:UInt256, rhs:UInt256)->UInt256 {
    var a = unsafeBitCast((lhs, vU256()), vU512.self)
    var r = vU512()
    vLR512Shift(&a, rhs.asUInt32!, &r)
    return unsafeBitCast(r, (UInt256, UInt256).self).0
}
#endif
