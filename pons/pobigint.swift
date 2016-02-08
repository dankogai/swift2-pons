//
//  pobigint.swift
//  pons
//
//  Created by Dan Kogai on 2/5/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

///
/// Arbitrary-precision Signed Integer
///
public struct BigInt {
    public typealias UIntType = BigUInt
    public var unsignedValue = BigUInt()
    public var isSignMinus = false
    public init(_ bi:BigInt) {
        self.unsignedValue  = bi.unsignedValue
        self.isSignMinus    = bi.isSignMinus
    }
    public init(unsignedValue:BigUInt, isSignMinus:Bool=false) {
        self.unsignedValue = unsignedValue
        self.isSignMinus = isSignMinus
    }
    public init(_ bu:BigUInt)   { unsignedValue = bu }
    public init(_ u:UIntMax)    { unsignedValue = BigUInt(u) }
    public init(_ u:UInt)       { unsignedValue = BigUInt(u) }
    public init(_ i:IntMax)     { unsignedValue = BigUInt(Swift.abs(i)); isSignMinus = i < 0 }
    public init(_ i:Int)        { unsignedValue = BigUInt(Swift.abs(i)); isSignMinus = i < 0 }
    public init(_ d:Double)     { unsignedValue = BigUInt(Swift.abs(d)); isSignMinus = d < 0 }
    public init(){}
    // conversions
    public func toIntMax()->IntMax {
        if self.abs > BigInt(IntMax.max) {
            fatalError("too large for Int64")
        }
        let a = unsignedValue.toIntMax()
        return self.isSignMinus ? -a : +a
    }
    public func toUIntMax()->UIntMax {
        return self.unsignedValue.toUIntMax()
    }
    public func toDouble() -> Double {
        return Double(isSignMinus ? -1.0 : +1.0) * unsignedValue.toDouble()
    }
    public var msbAt:Int { return unsignedValue.msbAt }
    public static let allZeros = BigInt(0)
    public var abs:BigInt { return self.isSignMinus ? -self : self }
    public static func abs(bi:BigInt)->BigInt { return bi.abs }
    public func toString(base:Int = 10)-> String {
        return (self.isSignMinus ? "-" : "") + self.unsignedValue.toString(base)
    }
    public var description:String { // CustomStringConvertible
        return self.toString()
    }
    public var debugDescription:String {    //  CustomDebugStringConvertible
        return (self.isSignMinus ? "-" : "+") + self.unsignedValue.debugDescription
    }
    // no overflow for BigInt, period.
    public static func addWithOverflow(lhs:BigInt, _ rhs:BigInt)->(BigInt, overflow:Bool) {
        return (lhs + rhs, false)
    }
    public static func subtractWithOverflow(lhs:BigInt, _ rhs:BigInt)->(BigInt, overflow:Bool) {
        return (lhs - rhs, false)
    }
    public static func multiplyWithOverflow(lhs:BigInt, _ rhs:BigInt)->(BigInt, overflow:Bool) {
        return (lhs * rhs, false)
    }
    public static func divmod(lhs:BigInt, _ rhs:BigInt)->(BigInt, BigInt) {
        let (q, r) = BigUInt.divmod(lhs.unsignedValue, rhs.unsignedValue)
        return (
            BigInt(unsignedValue:q, isSignMinus: Bool.xor(lhs.isSignMinus, rhs.isSignMinus)),
            BigInt(unsignedValue:r, isSignMinus: lhs.isSignMinus)
        )
    }
    public static func divideWithOverflow(lhs:BigInt, _ rhs:BigInt)->(BigInt, overflow:Bool) {
        return (divmod(lhs, rhs).0, false)
    }
    public static func remainderWithOverflow(lhs:BigInt, _ rhs:BigInt)->(BigInt, overflow:Bool) {
        return (divmod(lhs, rhs).1, false)
    }
}
public func abs(bi:BigInt)->BigInt { return bi.abs }
public func ==(lhs:BigInt, rhs:BigInt)->Bool {
    return lhs.isSignMinus == rhs.isSignMinus && lhs.unsignedValue == rhs.unsignedValue
}
public func <(lhs:BigInt, rhs:BigInt)->Bool {
    if lhs.isSignMinus == rhs.isSignMinus {
        return lhs.isSignMinus
            ? lhs.unsignedValue > rhs.unsignedValue
            : lhs.unsignedValue < rhs.unsignedValue
    }
    return lhs.isSignMinus ? true : false
}
public prefix func -(bi:BigInt)->BigInt {
    return BigInt(unsignedValue:bi.unsignedValue, isSignMinus:!bi.isSignMinus)
}
public prefix func +(bi:BigInt)->BigInt {
    return bi
}
public func +(lhs:BigInt, rhs:BigInt)->BigInt {
    if lhs.isSignMinus != rhs.isSignMinus {
        let unsignedValue = lhs.unsignedValue < rhs.unsignedValue
            ?   rhs.unsignedValue - lhs.unsignedValue
            :   lhs.unsignedValue - rhs.unsignedValue
        return BigInt(
            unsignedValue: unsignedValue,
            isSignMinus: Bool.xor(lhs.unsignedValue < rhs.unsignedValue, lhs.isSignMinus)
        )
    }
    return BigInt(
        unsignedValue: lhs.unsignedValue + rhs.unsignedValue,
        isSignMinus: lhs.isSignMinus
    )
}
public func -(lhs:BigInt, rhs:BigInt)->BigInt {
    return lhs + (-rhs)
}
// Bitwise ops
public prefix func ~(bs:BigInt)->BigInt {
    return BigInt(unsignedValue: ~bs.unsignedValue)
}
public func &(lhs:BigInt, rhs:BigInt)->BigInt {
    return BigInt(unsignedValue:lhs.unsignedValue & rhs.unsignedValue)
}
public func |(lhs:BigInt, rhs:BigInt)->BigInt {
    return BigInt(unsignedValue:lhs.unsignedValue | rhs.unsignedValue)
}
public func ^(lhs:BigInt, rhs:BigInt)->BigInt {
    return BigInt(unsignedValue:lhs.unsignedValue ^ rhs.unsignedValue)
}
public func <<(lhs:BigInt, rhs:BigInt)->BigInt {
    return BigInt(
        unsignedValue:  lhs.unsignedValue << rhs.unsignedValue,
        isSignMinus:    lhs.isSignMinus
    )
}
public func >>(lhs:BigInt, rhs:BigInt)->BigInt {
    return BigInt(
        unsignedValue:  lhs.unsignedValue >> rhs.unsignedValue,
        isSignMinus:    lhs.isSignMinus
    )
}
// arithmetic operators
public func *(lhs:BigInt, rhs:BigInt)->BigInt {
    return BigInt(
        unsignedValue:  lhs.abs.unsignedValue * rhs.unsignedValue,
        isSignMinus:    Bool.xor(lhs.isSignMinus, rhs.isSignMinus)
    )
}
public func &*(lhs:BigInt, rhs:BigInt)->BigInt {
    return lhs * rhs
}
public func /(lhs:BigInt, rhs:BigInt)->BigInt {
    return BigInt.divmod(lhs, rhs).0
}
public func %(lhs:BigInt, rhs:BigInt)->BigInt {
    return BigInt.divmod(lhs, rhs).1
}
extension BigInt : POInt {
    public var asUnsigned:UIntType { return self.unsignedValue }
}
extension POInt {
    public var asBigInt:BigInt { return BigInt(self.toIntMax()) }
}
