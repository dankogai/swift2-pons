//
//  pobiguint.swift
//  pons
//
//  Created by Dan Kogai on 2/4/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

///
/// Arbitrary-precision Unsigned Integer
///
public struct BigUInt {
    public typealias DigitType = UInt32
    var digits = [DigitType]()  // Base 2**32 = 4294967296
    public static let precision = IntMax.max
    public init(_ s:BigUInt) {  // demanded by PONumber
        self.digits = s.digits
    }
    // init from built-in types
    public init(_ u:DigitType) {
        digits = [u]
    }
    public init(_ u:UIntMax) {
        digits = u <= UIntMax(DigitType.max)
            ? [DigitType(u & 0xFFFFffff)]
            : [DigitType(u & 0xFFFFffff), DigitType(u >> 32)]
    }
    public init(_ u:UInt) { self.init(UInt64(u)) }
    public init(_  i:Int) { self.init(UInt64(i)) }      // demanded by PONumber
    public init() {
        digits = [0]
    }
    public var asUInt64:UInt64? {
        return digits.count == 1 ? UInt64(digits[0])
            :  digits.count == 2 ? UInt64(digits[1]) << 32 | UInt64(digits[0])
            : nil
    }
    public func toUIntMax()->UIntMax {
        return self.asUInt64!
    }
    public func toIntMax()->IntMax {
        return self.asUInt64!.asInt64!
    }
    public var asDouble:Double? {
        let e = self.msbAt - 53
        if e < 0 { return Double(self.toUIntMax()) }
        let m = (self >> BigUInt(e)).toUIntMax()
        // print("\(__FILE__):\(__LINE__): e=\(e),m=\(m)")
        return Double.ldexp(Double(m), e)
    }
    public func toDouble() -> Double {
        return self.asDouble!
    }
}
// reverse conversions
public extension Int    { public init(_ bu:BigUInt){ self.init(bu.asInt!) } }
public extension UInt   { public init(_ bu:BigUInt){ self.init(bu.asUInt!) } }
public extension Double { public init(_ bu:BigUInt){ self.init(bu.asDouble!) } }
public extension Float  { public init(_ bu:BigUInt){ self.init(bu.asFloat!) } }
// must be Equatable
extension BigUInt: Equatable {}
public func == (lhs:BigUInt, rhs:BigUInt)->Bool {
    // return lhs.digits == rhs.digits // considered naive
    if lhs.digits.count != rhs.digits.count { return false }
    for i in 0..<lhs.digits.count {
        if lhs.digits[i] != rhs.digits[i] { return false }
    }
    return true
}
public func != (lhs:BigUInt, rhs:BigUInt)->Bool {
    // return !(lhs.digits == rhs.digits) // still considered naive
    if lhs.digits.count != rhs.digits.count { return true }
    for i in 0..<lhs.digits.count {
        if lhs.digits[i] != rhs.digits[i] { return true }
    }
    return false
}
// and Comparable
extension BigUInt: Comparable {}
public func < (lhs:BigUInt, rhs:BigUInt)->Bool {
    if lhs.digits.count > rhs.digits.count { return false }
    if lhs.digits.count < rhs.digits.count { return true }
    for i in (0..<lhs.digits.count).reverse() {
        if lhs.digits[i] > rhs.digits[i] { return false }
        if lhs.digits[i] < rhs.digits[i] { return true }
    }
    return false
}
// BigUInt as [Bit]
extension BigUInt : BitwiseOperationsType {
    public static let allZeros = BigUInt(0)
    public static let bitsPerDigit = 32
    /// stretch the internal array so it can accept d * 32 bits
    /// parameter d: number of digits
    public mutating func stretch(d:Int) {
        if digits.count <= d {   // stretch if necessary
            for _ in digits.count...d { digits.append(0) }
        }
    }
    /// trim uncessary upper digits
    public mutating func trim() {
        while digits.count > 1 {
            if digits[digits.count - 1] != 0 { return }
            digits.removeLast()
        }
    }
    /// init from raw value -- always trimmed
    public init(rawValue:[UInt32]) {
        self.digits = rawValue
        self.trim()
    }
    public subscript(i:Int)->Bit {
        get {
            let (index, offset) = (i / 32, i % 32)
            if digits.count <= index { return .Zero }
            return digits[index] & UInt32(1 << offset) == 0 ? .Zero : .One
        }
        set {
            let (index, offset) = (i / 32, i % 32)
            if newValue == .One {
                self.stretch(index)
                digits[index] |= UInt32(1 << offset)
            } else {
                if index < digits.count {    // set iff value exists
                    digits[index] &= ~UInt32(1 << offset)
                    self.trim()
                }
            }
        }
    }
    public static func binop(op:(DigitType,DigitType)->DigitType)
        ->(BigUInt,BigUInt)->BigUInt {
            return { lhs, rhs in
                let (l, r) = lhs.digits.count < rhs.digits.count ? (rhs, lhs) : (lhs, rhs)
                var value = l.digits
                for i in 0..<l.digits.count {
                    value[i] = op(value[i], i < r.digits.count ? r.digits[i] : 0)
                }
                return BigUInt(rawValue:value)
            }
    }
    /// bitwise `&` in functional form
    public static let bitAnd = BigUInt.binop(&)
    /// bitwise `|` in functional form
    public static let bitOr  = BigUInt.binop(|)
    /// bitwise `^` in functional form
    public static let bitXor = BigUInt.binop(^)
    /// bitwise `~` in functional form
    public static func bitNot(bs:BigUInt)->BigUInt {
        return BigUInt(rawValue: bs.digits.map{ ~$0 } )
    }
    /// bitwise `<<` in functional form
    public static func bitShiftL(lhs:BigUInt, _ rhs:DigitType)->BigUInt {
        if lhs == 0 { return lhs }
        let (index, offset) = (rhs / 32, rhs % 32)
        let blank = [DigitType](count:Int(index), repeatedValue:0)
        if offset == 0 { return BigUInt(rawValue: blank + lhs.digits) }
        var value = lhs.digits
        var carry:UInt32 = 0
        for i in 0..<value.count {
            value[i] = carry | (value[i] << offset)
            carry = lhs.digits[i] >> (32 - offset)
        }
        value.append(carry)
        return BigUInt(rawValue:blank + value)
    }
    public static func bitShiftL(lhs:BigUInt, _ rhs:BigUInt)->BigUInt {
        return bitShiftL(lhs, rhs.asUInt32!)
    }
    /// bitwise `>>` in functional form
    public static func bitShiftR(lhs:BigUInt, _ rhs:DigitType)->BigUInt {
        if lhs == 0 { return lhs }
        var value = lhs.digits
        let (index, offset) = (rhs / 32, rhs % 32)
        if value.count <= Int(index) {
            return 0
        }
        value.removeFirst(Int(index))
        if offset == 0 { return BigUInt(rawValue:value) }
        let e = 0
        let b = value.count
        let ol = offset
        let oh = 32 - ol
        let mask = ~0 >> oh
        value.append(0) // add sentinel
        for i in e..<b {
            value[i] = ((value[i+1] & mask) << oh) | (value[i] >> ol)
        }
        return BigUInt(rawValue:value)
    }
    public static func bitShiftR(lhs:BigUInt, _ rhs:BigUInt)->BigUInt {
        return bitShiftR(lhs, rhs.asUInt32!)
    }
}
// Bitwise ops
public prefix func ~(bs:BigUInt)->BigUInt {
    return BigUInt.bitNot(bs)
}
public func &(lhs:BigUInt, rhs:BigUInt)->BigUInt {
    return BigUInt.bitAnd(lhs, rhs)
}
public func &=(inout lhs:BigUInt, rhs:BigUInt) {
    lhs = lhs & rhs
}
public func |(lhs:BigUInt, rhs:BigUInt)->BigUInt {
    return BigUInt.bitOr(lhs, rhs)
}
public func |=(inout lhs:BigUInt, rhs:BigUInt) {
    lhs = lhs | rhs
}
public func ^(lhs:BigUInt, rhs:BigUInt)->BigUInt {
    return BigUInt.bitXor(lhs, rhs)
}
public func ^=(inout lhs:BigUInt, rhs:BigUInt) {
    lhs = lhs ^ rhs
}
public func <<(lhs:BigUInt, rhs:BigUInt)->BigUInt {
    return BigUInt.bitShiftL(lhs, rhs)
}
public func <<=(inout lhs:BigUInt, rhs:BigUInt) {
    // lhs = lhs << rhs; return // turns out to be too naive
    if lhs == 0 { return }
    let (index, offset) = (rhs / 32, rhs.asUInt32! % 32)
    while lhs.digits.count <= index.asInt {
        lhs.digits.insert(0, atIndex:0)
    }
    if offset == 0 { return }
    var carry:UInt32 = 0
    var tmp:UInt32 = 0
    for i in 0..<lhs.digits.count {
        tmp = lhs.digits[i] >> (32 - offset)
        lhs.digits[i] <<= offset
        lhs.digits[i] |= carry
        carry = tmp
    }
    if carry != 0 { lhs.digits.append(carry) }
}
public func >>(lhs:BigUInt, rhs:BigUInt)->BigUInt {
    return BigUInt.bitShiftR(lhs, rhs)
}
// addtition and subtraction
public extension BigUInt {
    /// BigUInt addition never overflows
    ///
    /// - returns: `(lhs + rhs, overflow:false)`
    public static func addWithOverflow(lhs:BigUInt, _ rhs:BigUInt)->(BigUInt, overflow:Bool) {
        if rhs == 0 { return (lhs, false) }
        var l = lhs
        l += lhs
        return (l, overflow:false)  // never overlows but protocol demands this
    }
    /// since BigUInt is unsigned, it overflows when `lhs < rhs`.
    ///
    /// - returns: (`lhs - rhs`, overflow:lhs < rhs)
    public static func subtractWithOverflow(lhs:BigUInt, _ rhs:BigUInt)->(BigUInt, overflow:Bool) {
        if rhs == 0 { return (lhs, false) }
        var l = lhs
        l -= rhs
        return (l, overflow: lhs < rhs) // overflow when `li
    }
    /// subtraction in functional form
    public static func subtract(lhs:BigUInt, _ rhs:BigUInt)->BigUInt {
        let result = subtractWithOverflow(lhs, rhs)
        if result.overflow {
            fatalError("arithmetic operation '\(lhs) - \(rhs)' (on type 'BigUInt') results in an overflow")
        }
        return result.0
    }
}
public func +(lhs:BigUInt, rhs:BigUInt)->BigUInt {
    // return BigUInt.add(lhs, rhs)
    var l = lhs
    l += rhs
    return l
}
public func +=(inout lhs:BigUInt, rhs:BigUInt) {
    // lhs = BigUInt.add(lhs, rhs); return // is too naive
    lhs.stretch(rhs.digits.count-1)
    var carry:UInt64 = 0
    for i in 0..<lhs.digits.count {
        carry += UInt64(lhs.digits[i]) + UInt64(i < rhs.digits.count ? rhs.digits[i] : 0)
        lhs.digits[i] = UInt32(carry & 0xffff_ffff)
        carry >>= 32
    }
    if carry != 0 { lhs.digits.append(UInt32(carry & 0xffff_ffff)) }
}
public prefix func +(bs:BigUInt)->BigUInt {
    return bs
}
public func -(lhs:BigUInt, rhs:BigUInt)->BigUInt {
    let result = BigUInt.subtractWithOverflow(lhs, rhs)
    if result.overflow {
        fatalError("arithmetic operation '\(lhs) - \(rhs)' (on type 'BigUInt') results in an overflow")
    }
    return result.0
}
public func -=(inout lhs:BigUInt, rhs:BigUInt) {
    // lhs = lhs - rhs; return // is too naive
    if rhs == 0 { return }
    var sub = rhs
    sub.stretch(lhs.digits.count-1)
    for i in 0..<sub.digits.count {
        sub.digits[i] = ~sub.digits[i]
    }
    var carry:UInt64 = 1
    for i in 0..<sub.digits.count {
        carry += UInt64(lhs.digits[i]) + UInt64(sub.digits[i])
        lhs.digits[i] = UInt32(carry & 0xffff_ffff)
        carry >>= 32
    }
    lhs.trim()
}
public prefix func -(bs:BigUInt)->BigUInt {
    return 0 - bs
}
// multiplication
public extension BigUInt {
    ///
    /// multiply by `single` digit
    ///
    public static func multiply32(lhs:BigUInt, _ rhs:DigitType)->BigUInt {
        var value = lhs.digits
        value.append(0) // sentinel
        var carry:UInt64 = 0
        for i in 0..<lhs.digits.count {
            carry = UInt64(value[i]) * UInt64(rhs) + (carry >> 32)
            value[i] = DigitType(carry & 0xffff_ffff)
        }
        value[lhs.digits.count] = DigitType(carry >> 32)
        return BigUInt(rawValue:value)
    }
    /// multiplication in functinal form.
    ///
    /// - returns: lhs * rhs
    public static func multiply(lhs:BigUInt, _ rhs:BigUInt)->BigUInt {
        var result = BigUInt()
        for i in 0..<rhs.digits.count {
            result += bitShiftL(multiply32(lhs, rhs.digits[i]), DigitType(i * 32))
        }
        return result
    }
    // multiplication never overflows
    public static func multiplyWithOverflow(lhs:BigUInt, _ rhs:BigUInt)->(BigUInt, overflow:Bool) {
        return (multiply(lhs, rhs), overflow:false)
    }
}
public func *(lhs:BigUInt, rhs:BigUInt)->BigUInt {
    return BigUInt.multiply(lhs, rhs)
}
public func &*(lhs:BigUInt, rhs:BigUInt)->BigUInt {
    return BigUInt.multiplyWithOverflow(lhs, rhs).0
}
// before we get down to division, let's define divmod32 and divmod8
// and use it to make it conform to CustomStringConvertible
extension BigUInt : CustomStringConvertible, CustomDebugStringConvertible {
    public static func divmod32(lhs:BigUInt, _ rhs:DigitType)->(BigUInt, DigitType) {
        var value = lhs.digits
        // value.append(0) // sentinel
        var carry:UInt64 = 0
        for i in (0..<lhs.digits.count).reverse() {
            carry = UInt64(carry % UInt64(rhs)) << 32 + UInt64(value[i])
            value[i] = UInt32(carry / UInt64(rhs))
        }
        return (BigUInt(rawValue:value), UInt32(carry % UInt64(rhs)))
    }
    public static func divmod8(lhs:BigUInt, _ rhs:Int8)->(BigUInt, Int) {
        let (q, r) = divmod32(lhs, DigitType(rhs))
        return (q, Int(r))
    }
}
// now let's get division done
public extension BigUInt {
    public var msbAt:Int {
        return (self.digits.count-1) * 32 + self.digits.last!.msbAt
    }
    /// binary long division
    ///
    /// cf. https://en.wikipedia.org/wiki/Division_algorithm#Integer_division_.28unsigned.29_with_remainder
    public static func divmodLong(lhs:BigUInt, _ rhs:BigUInt)->(BigUInt, BigUInt) {
        var q = BigUInt(0)
        var r = BigUInt(0)
        for i in (0...lhs.msbAt).lazy.reverse() {
            r <<= BigUInt(1)
            r[0] = lhs[i]
            if r >= rhs {
                r -= rhs
                q[i] = .One
            }
        }
        return (q, r)
    }
    /// - returns: (quotient, remainder)
    public static func divmod(lhs:BigUInt, _ rhs:BigUInt)->(BigUInt, BigUInt) {
        guard rhs != BigUInt(0) else { fatalError("division by zero") }
        if lhs == rhs { return (BigUInt(1), BigUInt(0)) }
        if lhs < rhs  { return (BigUInt(0), lhs) }
        if rhs <= BigUInt(UInt32.max) {
            let (q, r) = divmod32(lhs, rhs.asUInt32!)
            return (q, BigUInt(r))
        }
        return divmodLong(lhs, rhs)
    }
    // no overflow
    public static func divideWithOverflow(lhs:BigUInt, _ rhs:BigUInt)->(BigUInt, overflow:Bool) {
        return (divmod(lhs, rhs).0, false)
    }
    // no overflow
    public static func remainderWithOverflow(lhs:BigUInt, _ rhs:BigUInt)->(BigUInt, overflow:Bool) {
        return (divmod(lhs, rhs).1, false)
    }
}
public func /(lhs:BigUInt, rhs:BigUInt)->BigUInt {
    return BigUInt.divmod(lhs, rhs).0
}
public func %(lhs:BigUInt, rhs:BigUInt)->BigUInt {
    return BigUInt.divmod(lhs, rhs).1
}
// Now that we are done with all requirements, Let Swift know that!
extension BigUInt: POUInt {
    public typealias IntType = BigInt
    public var asSigned:IntType? { return 0 < self ? nil : BigInt(unsignedValue:self) }
}
extension POUInt {
    public var asBigUInt:BigUInt { return BigUInt(self.toUIntMax()) }
}
