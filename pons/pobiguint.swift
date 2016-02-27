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
    public var digits = [DigitType]()  // Base 2**32 = 4294967296
    public static let precision = Int.max - 1
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
    public var asUInt32:UInt32? {
        return digits.count == 1 ? digits[0] : nil
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
    private static func binopAssign(op:(DigitType,DigitType)->DigitType)->(inout BigUInt,BigUInt)->() {
        return { lhs, rhs in
            lhs.stretch(rhs.digits.count-1)
            for i in 0..<lhs.digits.count {
                lhs.digits[i] = op(lhs.digits[i], i < rhs.digits.count ? rhs.digits[i] : 0)
            }
        }
    }
    /// bitwise `&` in functional form
    public static let bitAnd = BigUInt.binop(&)
    /// bitwise `&=` in functional form
    private static let bitAndAssign = BigUInt.binopAssign(&)
    /// bitwise `|` in functional form
    public static let bitOr  = BigUInt.binop(|)
    /// bitwise `|=` in functional form
    private static let bitOrAssign  = BigUInt.binopAssign(|)
    /// bitwise `^` in functional form
    private static let bitXor = BigUInt.binop(^)
    /// bitwise `^=` in functional form
    public static let bitXorAssign = BigUInt.binopAssign(^)
    /// bitwise `~` in functional form
    public static func bitNot(bs:BigUInt)->BigUInt {
        return BigUInt(rawValue: bs.digits.map{ ~$0 } )
    }
    /// bitwise `<<` in functional form
    public static func bitShiftL(lhs:BigUInt, _ rhs:DigitType)->BigUInt {
        return lhs << rhs.asInt!
    }
    public static func bitShiftL(lhs:BigUInt, _ rhs:BigUInt)->BigUInt {
        return lhs << rhs
    }
    /// bitwise `>>` in functional form
    public static func bitShiftR(lhs:BigUInt, _ rhs:DigitType)->BigUInt {
        return lhs >> rhs.asInt!
    }
    public static func bitShiftR(lhs:BigUInt, _ rhs:BigUInt)->BigUInt {
        return lhs >> rhs
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
    BigUInt.bitAndAssign(&lhs, rhs)
}
public func |(lhs:BigUInt, rhs:BigUInt)->BigUInt {
    return BigUInt.bitOr(lhs, rhs)
}
public func |=(inout lhs:BigUInt, rhs:BigUInt) {
    BigUInt.bitOrAssign(&lhs, rhs)
}
public func ^(lhs:BigUInt, rhs:BigUInt)->BigUInt {
    return BigUInt.bitXor(lhs, rhs)
}
public func ^=(inout lhs:BigUInt, rhs:BigUInt) {
    BigUInt.bitXorAssign(&lhs, rhs)
}
public func <<=(inout lhs:BigUInt, rhs:BigUInt) {
    lhs <<= rhs.asInt!
}
public func <<=(inout lhs:BigUInt, rhs:Int) {
    // lhs = lhs << rhs; return // turns out to be too naive
    if lhs == 0 { return }
    let (index, offset) = (rhs / 32, UInt32(rhs) % 32)
    while lhs.digits.count <= index {
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
public func <<(lhs:BigUInt, rhs:Int)->BigUInt {
    if lhs == 0 { return lhs }
    let (index, offset) = (rhs / 32, BigUInt.DigitType(rhs) % 32)
    let blank = Array<BigUInt.DigitType>(count:index, repeatedValue:0)
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
public func <<(lhs:BigUInt, rhs:BigUInt)->BigUInt {
    return lhs << rhs.asInt!
    // return BigUInt.bitShiftL(lhs, UInt32(rhs))
}
public func >>=(inout lhs:BigUInt, rhs:BigUInt) {
    lhs >>= rhs.asInt!
}
public func >>=(inout lhs:BigUInt, rhs:Int) {
    if lhs == 0 { return }
    let (index, offset) = (rhs / 32, UInt32(rhs) % 32)
    if lhs.digits.count <= index {
        // lhs.digits = [0]
        lhs.digits.removeAll()
        lhs.digits.append(0)
    }
    lhs.digits.removeFirst(index)
    if offset == 0 { return }
    let e = 0
    let b = lhs.digits.count
    let ol = offset
    let oh = 32 - ol
    let mask = ~0 >> oh
    lhs.digits.append(0) // add sentinel
    for i in e..<b {
        lhs.digits[i] = ((lhs.digits[i+1] & mask) << oh) | (lhs.digits[i] >> ol)
    }
    lhs.trim()
}
public func >>(lhs:BigUInt, rhs:Int)->BigUInt {
    var result = lhs
    result >>= rhs
    return result
    //return BigUInt.bitShiftR(lhs, rhs)
}
public func >>(lhs:BigUInt, rhs:BigUInt)->BigUInt {
    return lhs >> rhs.asInt!
}
// addition and subtraction
public extension BigUInt {
    /// BigUInt addition never overflows
    ///
    /// - returns: `(lhs + rhs, overflow:false)`
    public static func addWithOverflow(lhs:BigUInt, _ rhs:BigUInt)->(BigUInt, overflow:Bool) {
        if rhs == 0 { return (lhs, false) }
        var l = lhs
        l += rhs
        return (l, overflow:false)  // never overlows but protocol demands this
    }
    /// subtraction in functional form
    public static func add(lhs:BigUInt, _ rhs:BigUInt)->BigUInt {
        let result = addWithOverflow(lhs, rhs)
        if result.overflow {
            fatalError("arithmetic operation '\(lhs) + \(rhs)' (on type 'BigUInt') results in an overflow")
        }
        return result.0
    }
    /// since BigUInt is unsigned, it overflows when `lhs < rhs`.
    ///
    /// - returns: (`lhs - rhs`, overflow:lhs < rhs)
    public static func subtractWithOverflow(lhs:BigUInt, _ rhs:BigUInt)->(BigUInt, overflow:Bool) {
        if rhs == 0 { return (lhs, false) }
        var l = lhs
        l -= rhs
        return (l, overflow: lhs < rhs) // overflow when lhs < rhs
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
public func &+(lhs:BigUInt, rhs:BigUInt)->BigUInt {
    return BigUInt.addWithOverflow(lhs, rhs).0
}
public func +(lhs:BigUInt, rhs:BigUInt)->BigUInt {
    return BigUInt.add(lhs, rhs)
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
    lhs.trim()
}
public prefix func +(bs:BigUInt)->BigUInt {
    return bs
}
public func &-(lhs:BigUInt, rhs:BigUInt)->BigUInt {
    return BigUInt.subtractWithOverflow(lhs, rhs).0
}
public func -(lhs:BigUInt, rhs:BigUInt)->BigUInt {
    return BigUInt.subtract(lhs, rhs)
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
    /// Integer reciprocal
    public func reciprocal(shift:Int=63)->BigUInt {
        let bits = max(shift, self.msbAt + 1)
        var inv0 = self
        if self.msbAt + 1 < bits {
            inv0 <<= BigUInt(bits - (self.msbAt + 1))
        }
        var inv:BigUInt = BigUInt(1) << bits
        let two = inv * inv * 2
        for _ in 0...bits {
            inv = inv0 * (two - self * inv0)    // Newton-Raphson core
            inv >>= inv.msbAt - bits            // truncate
            if inv == inv0 { break }
            inv0 = inv
        }
        return inv
    }
    ///
    /// Newton-Raphson division
    ///
    public static func divmodNR(lhs:BigUInt, _ rhs:BigUInt)->(BigUInt, BigUInt) {
        let bits = rhs.msbAt + 1
        var inv0 = rhs
        var inv:BigUInt = BigUInt(1) << bits
        let two = inv * inv * 2
        for _ in 0...bits {
            inv = inv0 * (two - rhs * inv0)     // Newton-Raphson core
            inv >>= BigUInt(inv.msbAt - bits)   // truncate
            if inv == inv0 { break }
            inv0 = inv
        }
        var (q, r) = (BigUInt(0), lhs)
        while r > rhs {
            let q0 = (r * inv) >> (bits*2)
            q += q0
            r -= rhs * q0

        }
        return r == rhs ? (q + 1, 0) : (q, r)
    }
    ///
    /// binary long division
    ///
    /// cf. https://en.wikipedia.org/wiki/Division_algorithm#Integer_division_.28unsigned.29_with_remainder
    public static func divmodLongBit(lhs:BigUInt, _ rhs:BigUInt)->(BigUInt, BigUInt) {
        var q = BigUInt(0)
        var r = BigUInt(0)
        for i in (0...lhs.msbAt).lazy.reverse() {
            r <<= 1
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
        // return divmodLongBit(lhs, rhs)
        return divmodNR(lhs, rhs)
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
// Now that we are done with all requirements, Let Swift know that!
extension BigUInt: POUInt {
    public typealias IntType = BigInt
    public var asSigned:IntType? { return BigInt(unsignedValue:self) }
    public var asBigUInt:BigUInt? { return self }
}
// And add methods to POUInt that depends on BigUInt
public extension POUInt {
    /// - returns: `(x * y) % m` witout overflow in exchange for speed
    public static func mulmod(x:Self, _ y:Self, _ m:Self)->Self {
        if (m == 0) { fatalError("modulo by zero") }
        if (m == 1) { return 1 }
        if Self.self == BigUInt.self {
            return (x * y) % m  // no overflow
        }
        var a = x % m;
        if a == 0 { return 0 }
        var b = y % m;
        if b == 0 { return 0 }
        var r:Self = 0;
        while a > 0 {
            if a & 1 == 1 { r = Self.addWithOverflow(r, b).0 % m }
            a >>= 1
            b = (b << 1) % m
        }
        return r
        
    }
    // powmod related codes //
    public static func pow(lhs:Self, _ rhs:Self, mod:Self=Self(1))->Self {
        let op = mod == Self(1)
            ? { Self.multiplyWithOverflow($0, $1).0 }
            : { powmod($0, $1, mod:mod) }
        return rhs < Self(1) ? Self(1) : power(lhs, rhs, op:op)
    }
    /// modular reciprocal of `self`
    public var modinv:Self {
        var m = Self(0)
        var t = Self(0)
        var r = Self(2) << Self(self.msbAt)
        var i = Self(1)
        // print("\(__FILE__):\(__LINE__): t=\(t),r=\(r),i=\(i)")
        while r > Self(1) {
            if t & Self(1) == Self(0) {
                t += self
                m += i
            }
            t >>= Self(1)
            r >>= Self(1)
            i <<= Self(1)
        }
        return m
    }
    /// montgomery reduction
    public static func redc(n:Self, _ m:Self)->Self {
        let bits = Self(m.msbAt + 1)
        let mask = (Self(1) << bits) - 1
        let minv = m.modinv
        // print("\(__FILE__):\(__LINE__): n=\(n),bits=\(bits), minv=\(minv)")
        let t = (n + ((n * minv) & mask) * m) >> bits
        return t >= m ? t - m : t
    }
    ///
    /// Modular exponentiation. a.k.a `modpow`.
    ///
    /// - returns: `b ** x mod m`
    public static func powmod(b:Self, _ x:Self, mod m:Self)->Self {
        // return b < 1 ? 1 : power(b, x){ mulmod($0, $1, m) }
        if Self.self != BigUInt.self  { // force BigUInt to avoid overflow
            let totalbits = (b.msbAt + 1) + (x.msbAt + 1) + (m.msbAt + 1)
            if Self.precision <= totalbits {
                return Self(BigUInt.powmod(b.asBigUInt!, x.asBigUInt!, mod:m.asBigUInt!))
            }
            if Self.precision < UIntMax.precision {
                return Self(UIntMax.powmod(b.asUInt64!, x.asUInt64!, mod:m.asUInt64!))
            }
        }
        let bits = Self(m.msbAt + 1)
        let mask = (Self(1) << bits) - 1
        let minv = m.modinv
        let r1 = Self(1) << bits
        let r2 = Self.mulmod(r1, r1, m)
        let innerRedc:Self->Self = { n in
            // print("\(__FILE__):\(__LINE__): n=\(n),bits=\(bits), minv=\(minv)")
            // let t = (n + (Self.multiplyWithOverflow(n, minv).0 & mask) * m) >> bits
            let nminv =   Self.multiplyWithOverflow(n, minv).0
            let nminvmm = Self.multiplyWithOverflow(nminv & mask, m).0
            let t = Self.addWithOverflow(n, nminvmm).0 >> bits
            return t >= m ? t - m : t
        }
        let innerMulMod:(Self,Self)->Self = { (a, b) in
            let ma = innerRedc(a * r2)
            let mb = innerRedc(b * r2)
            return innerRedc(innerRedc(ma * mb))
            //return innerRedc(innerRedc(a * b) * r2)
        }
        // print("\(__FILE__):\(__LINE__): m=\(m), bits=\(bits), minv=\(minv), r2=\(r2)")
        if x < 0 {
            fatalError("negative exponent unsupported")
        }
        if x == 0 {
            return 1 % m
        }
        var r = b
        var t = b, n = x - Self(1)
        while n > Self(0) {
            if n & Self(1) == Self(1) {
                r = innerMulMod(r, t)
            }
            n >>= Self(1)
            t = innerMulMod(t, t)
        }
        return r
    }
}
