//
//  pointeger.swift
//  pons
//
//  Created by Dan Kogai on 2/4/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

public typealias POSwiftInteger = IntegerType

///
/// Protocol-oriented integer, signed or unsigned.
///
/// For the sake of protocol-oriented programming,
/// consider extend this protocol first before extending each integer type.
///
public protocol POInteger : POComparableNumber,
    RandomAccessIndexType, IntegerLiteralConvertible, _BuiltinIntegerLiteralConvertible
{
    // from IntegerArithmeticType
    static func addWithOverflow(lhs: Self, _ rhs: Self) -> (Self, overflow: Bool)
    static func subtractWithOverflow(lhs: Self, _ rhs: Self) -> (Self, overflow: Bool)
    static func multiplyWithOverflow(lhs: Self, _ rhs: Self) -> (Self, overflow: Bool)
    static func divideWithOverflow(lhs: Self, _ rhs: Self) -> (Self, overflow: Bool)
    static func remainderWithOverflow(lhs: Self, _ rhs: Self) -> (Self, overflow: Bool)
    func %(lhs: Self, rhs: Self) -> Self
    // from BitwiseOperationsType
    func &(lhs: Self, rhs: Self) -> Self
    func |(lhs: Self, rhs: Self) -> Self
    func ^(lhs: Self, rhs: Self) -> Self
    prefix func ~(x: Self) -> Self
    // strangely they did not exist
    func <<(_:Self,_:Self)->Self
    func >>(_:Self,_:Self)->Self
    // init?(_:String, radix:Int)
    func toDouble()->Double
    static var precision:Int { get }
    // the most significant bit
    var msbAt:Int { get }
    //
    var asUInt64:UInt64? { get }
    var asUInt32:UInt32? { get }
    var asUInt16:UInt16? { get }
    var asUInt8:UInt8?   { get }
    var asUInt:UInt?     { get }
    var asInt64:Int64?   { get }
    var asInt32:Int32?   { get }
    var asInt16:Int16?   { get }
    var asInt8:Int8?     { get }
    var asInt:Int?       { get }
}
// give away arithmetic operators
public func +<I:POInteger>(lhs:I, rhs:I)->I {
    let (result, overflow) = I.addWithOverflow(lhs, rhs)
    if overflow { fatalError("overflow: \(lhs) + \(rhs)") }
    return result
}
public func -<I:POInteger>(lhs:I, rhs:I)->I {
    let (result, overflow) = I.subtractWithOverflow(lhs, rhs)
    if overflow { fatalError("overflow: \(lhs) - \(rhs)") }
    return result
}
public func *<I:POInteger>(lhs:I, rhs:I)->I {
    let (result, overflow) = I.multiplyWithOverflow(lhs, rhs)
    if overflow { fatalError("overflow: \(lhs) * \(rhs)") }
    return result
}
public func /<I:POInteger>(lhs:I, rhs:I)->I {
    let (result, overflow) = I.divideWithOverflow(lhs, rhs)
    if overflow { fatalError("overflow: \(lhs) / \(rhs)") }
    return result
}
public func %<I:POInteger>(lhs:I, rhs:I)->I {
    let (result, overflow) = I.remainderWithOverflow(lhs, rhs)
    if overflow { fatalError("overflow: \(lhs) % \(rhs)") }
    return result
}
// give away &op
//public func &+<I:POInteger>(lhs:I, rhs:I)->I {
//    return I.addWithOverflow(lhs, rhs).0
//}
//public func &-<I:POInteger>(lhs:I, rhs:I)->I {
//    return I.subtractWithOverflow(lhs, rhs).0
//}
//public func &*<I:POInteger>(lhs:I, rhs:I)->I {
//    return I.multiplyWithOverflow(lhs, rhs).0
//}
// give away op=
public func %=<I:POInteger>(inout lhs:I, rhs:I) {
    lhs = lhs % rhs
}
public func &=<I:POInteger>(inout lhs:I, rhs:I) {
    lhs = lhs & rhs
}
public func |=<I:POInteger>(inout lhs:I, rhs:I) {
    lhs = lhs | rhs
}
public func ^=<I:POInteger>(inout lhs:I, rhs:I) {
    lhs = lhs ^ rhs
}
public func <<=<I:POInteger>(inout lhs:I, rhs:I) {
    lhs = lhs << rhs
}
public func >>=<I:POInteger>(inout lhs:I, rhs:I) {
    lhs = lhs >> rhs
}
public extension POInteger {
    /// IntegerLiteralConvertible by Default
    public init(integerLiteral:Int) {
        self.init(integerLiteral)
    }
    /// _BuiltinIntegerLiteralConvertible by Default
    public init(_builtinIntegerLiteral:_MaxBuiltinIntegerType) {
        self.init(Int(_builtinIntegerLiteral: _builtinIntegerLiteral))
    }
    // from BitwiseOperationsType
    public static var allZeros: Self { return 0 }
    // RandomAccessIndexType by default
    public func successor() -> Self {
        return self + 1
    }
    public func predecessor() -> Self {
        return self - 1
    }
    public func advancedBy(n: Int) -> Self {
        return self + Self(n)
    }
    //
    public init(_ v:UInt64) { self.init(v.asInt!) }
    public init(_ v:UInt32) { self.init(v.asInt!) }
    public init(_ v:UInt16) { self.init(v.asInt!) }
    public init(_ v:UInt8)  { self.init(v.asInt!) }
    public init(_ v:Int64)  { self.init(v.asInt!) }
    public init(_ v:Int32)  { self.init(v.asInt!) }
    public init(_ v:Int16)  { self.init(v.asInt!) }
    public init(_ v:Int8)   { self.init(v.asInt!) }
    public init(_ d:Double) { self.init(Int(d)) }
    public var asDouble:Double?  { return self.toDouble() }
    public var asFloat:Float?    { return Float(self.toDouble()) }
    //
    /// default implementation.  you should override it
    public static func divmod(lhs:Self, _ rhs:Self)->(Self, Self) {
        return (lhs / rhs, lhs % rhs)
    }
    ///
    /// Generalized power func
    ///
    /// the end result is the same as `(1..<n).reduce(lhs, combine:op)`
    /// but it is faster by [exponentiation by squaring].
    ///
    ///     power(2, 3){ $0 + $1 }          // 2 + 2 + 2 == 6
    ///     power("Swift", 3){ $0 + $1 }    // "SwiftSwiftSwift"
    ///
    /// In exchange for efficiency, `op` must be commutable.
    /// That is, `op(x, y) == op(y, x)` is true for all `(x, y)`
    ///
    /// [exponentiation by squaring]: https://en.wikipedia.org/wiki/Exponentiation_by_squaring
    ///
    public static func power<L>(lhs:L, _ rhs:Self, op:(L,L)->L)->L {
        if rhs < Self(1) {
            fatalError("negative exponent unsupported")
        }
        var r = lhs
        var t = lhs, n = rhs - Self(1)
        while n > Self(0) {
            if n & Self(1) == Self(1) {
                r = op(r, t)
            }
            n >>= Self(1)
            t = op(t, t)
        }
        return r
    }
    /// Integer square root
    public static func sqrt(n:Self)->Self {
        if n == 0 { return 0 }
        if n == 1 { return 1 }
        var xk = n >> Self(n.msbAt / 2)
        repeat {
            let xk1 = (xk + n / xk) >> 1 // /2
            if xk1 >= xk { return xk }
            xk = xk1
        } while true
    }
}

public typealias POSwiftUInt = UnsignedIntegerType

///
/// Protocol-oriented unsigned integer.  All built-ins already conform to this.
///
/// For the sake of protocol-oriented programming,
/// consider extend this protocol first before extending each unsigned integer type.
///
public protocol POUInt: POInteger, StringLiteralConvertible, CustomDebugStringConvertible {
    init (_:UInt)
    init (_:UIntMax)
    func toUIntMax()->UIntMax
    typealias IntType:POSignedNumber    // its correspoinding singed type
    //init(_:IntType)         // must be capable of initializing from it
    var asSigned:IntType? { get }
}
public extension POUInt {
    public init(_ v:UInt64) { self.init(v.toUIntMax()) }
    public init(_ v:UInt32) { self.init(v.toUIntMax()) }
    public init(_ v:UInt16) { self.init(v.toUIntMax()) }
    public init(_ v:UInt8)  { self.init(v.toUIntMax()) }
    /// number of significant bits ==  sizeof(Self) * 8
    public static var precision:Int {
        return sizeof(Self) * 8
    }
    ///
    /// Returns the index of the most significant bit of `self`
    /// or `-1` if `self == 0`
    public var msbAt:Int { return self.toUIntMax().msbAt }
    //
    // from IntegerArithmeticType
    public static func addWithOverflow(lhs: Self, _ rhs: Self) -> (Self, overflow: Bool) {
        let (result, overflow) = UInt.addWithOverflow(lhs.asUInt!, rhs.asUInt!)
        return (Self(result), overflow)
    }
    public static func subtractWithOverflow(lhs: Self, _ rhs: Self) -> (Self, overflow: Bool) {
        let (result, overflow) = UInt.subtractWithOverflow(lhs.asUInt!, rhs.asUInt!)
        return (Self(result), overflow)
    }
    public static func multiplyWithOverflow(lhs: Self, _ rhs: Self) -> (Self, overflow: Bool) {
        let (result, overflow) = UInt.multiplyWithOverflow(lhs.asUInt!, rhs.asUInt!)
        return (Self(result), overflow)
    }
    public static func divideWithOverflow(lhs: Self, _ rhs: Self) -> (Self, overflow: Bool) {
        let (result, overflow) = UInt.divideWithOverflow(lhs.asUInt!, rhs.asUInt!)
        return (Self(result), overflow)
    }
    public static func remainderWithOverflow(lhs: Self, _ rhs: Self) -> (Self, overflow: Bool) {
        let (result, overflow) = UInt.remainderWithOverflow(lhs.asUInt!, rhs.asUInt!)
        return (Self(result), overflow)
    }
    // POInteger conformance
    public var asUInt64:UInt64? { return UInt64(self.toUIntMax()) }
    public var asUInt32:UInt32? { return UInt32(self.toUIntMax()) }
    public var asUInt16:UInt16? { return UInt16(self.toUIntMax()) }
    public var asUInt8:UInt8?   { return UInt8(self.toUIntMax()) }
    public var asUInt:UInt?     { return UInt(self.toUIntMax()) }
    public var asInt64:Int64? {
        let ux = self.toUIntMax()
        return UInt64(Int64.max) < ux ? nil : Int64(ux)
    }
    public var asInt32:Int32? {
        let ux = self.toUIntMax()
        return UInt64(Int32.max) < ux ? nil : Int32(ux)
    }
    public var asInt16:Int16? {
        let ux = self.toUIntMax()
        return UInt64(Int16.max) < ux ? nil : Int16(ux)
    }
    public var asInt8:Int8? {
        let ux = self.toUIntMax()
        return UInt64(Int8.max) < ux ? nil : Int8(ux)
   }
    public var asInt:Int? {
        let ux = self.toUIntMax()
        return UInt64(Int.max) < ux ? nil : Int(ux)
    }
    public func toDouble()->Double { return Double(self.toUIntMax()) }
    ///
    /// `self.toString()` uses this to extract digits
    ///
    public static func divmod8(lhs:Self, _ rhs:Int8)->(Self, Int) {
        let denom = Self(rhs.asInt!)
        return (lhs / denom, (lhs % denom).asInt!)
    }
    /// returns quotient and remainder all at once.
    ///
    /// we give you the default you should override this for efficiency
    public static func divmod8(lhs:Self, _ rhs:Self)->(Self, Self) {
        return (lhs / rhs, lhs % rhs)
    }
    ///
    /// Stringifies `self` with base `radix` which defaults to `10`
    ///
    public func toString(base:Int = 10)-> String {
        guard 2 <= base && base <= 36 else {
            fatalError("base out of range. \(base) is not within 2...36")
        }
        var v = self
        var digits = [Int]()
        repeat {
            var r:Int
            (v, r) = Self.divmod8(v, Int8(base))
            digits.append(r)
        } while v != 0
        return digits.reverse().map{"\(POUtil.int2char[$0])"}.joinWithSeparator("")
    }
    
    // automagically CustomStringConvertible by defalut
    public var description:String {
        return self.toString()
    }
    // automagically CustomDebugStringConvertible
    public var debugDescription:String {
        return "0x" + self.toString(16)
    }
    public static func fromString(s: String, radix:Int = 10)->Self? {
        var (ss, b) = (s, radix)
        let si = s.startIndex
        if s[si] == "0" {
            let sis = si.successor()
            if s[sis] == "x" || s[sis] == "o" || s[sis] == "b" {
                ss = s[sis.successor()..<s.endIndex]
                b = s[sis] == "x" ? 16 : s[sis] == "o" ? 8 : 2
            }
        }
        var result = Self(0)
        for c in ss.lowercaseString.characters {
            if let d = POUtil.char2int[c] {
                result *= Self(b)
                result += Self(d)
            } else {
                if c != "_" { return nil }
            }
        }
        return result
    }
    /// init() with String. Handles `0x`, `0b`, and `0o`
    ///
    /// ought to be `init?` but that makes Swift 2.1 irate :-(
    public init(_ s:String, radix:Int = 10) {
        self.init(Self.fromString(s, radix:radix)!)
    }
    public var hashValue : Int {    // slow but steady
        return self.debugDescription.hashValue
    }
    /// StringLiteralConvertible by Default
    public init(stringLiteral: String) {
        self.init(stringLiteral)
    }
    public init(unicodeScalarLiteral: String) {
        self.init(stringLiteral: "\(unicodeScalarLiteral)")
    }
    public init(extendedGraphemeClusterLiteral: String) {
        self.init(stringLiteral: extendedGraphemeClusterLiteral)
    }
    ///
    /// * `lhs ** rhs`
    /// * `lhs ** rhs % mod` if `mod !=` (aka `modpow` or `powmod`)
    ///
    /// note only `rhs` must be an integer.
    ///
    public static func pow<L:POUInt>(lhs:L, _ rhs:Self)->L {
        return rhs < Self(1) ? L(1) : power(lhs, rhs){ L.multiplyWithOverflow($0, $1).0 }

    }
    /// true if self is power of 2
    public var isPowerOf2:Bool {
        return self != 0 && self & (self - 1) == 0
    }
}
//
//public func &<U:POUInt>(lhs:U, rhs:U)->U {
//    return U(lhs.toUIntMax() & rhs.toUIntMax())
//}
//public func |<U:POUInt>(lhs:U, rhs:U)->U {
//    return U(lhs.toUIntMax() | rhs.toUIntMax())
//}
//public func ^<U:POUInt>(lhs:U, rhs:U)->U {
//    return U(lhs.toUIntMax() ^ rhs.toUIntMax())
//}
//public func << <U:POUInt>(lhs:U, rhs:U)->U {
//    return U(lhs.toUIntMax() << rhs.toUIntMax())
//}
//public func >> <U:POUInt>(lhs:U, rhs:U)->U {
//    return U(lhs.toUIntMax() << rhs.toUIntMax())
//}
//
extension UInt64:   POUInt {
    public typealias IntType = Int64
    public var msbAt:Int {
        return self <= UInt64(UInt32.max)
            ? UInt32(self).msbAt
            : UInt32(self >> 32).msbAt + 32
    }
    public var asSigned:IntType? { return UInt64(Int64.max) < self ? nil : IntType(self) }
}
extension UInt32:   POUInt {
    public typealias IntType = Int32
    public var msbAt:Int {
        return Double.frexp(Double(self)).1 - 1
    }
    public var asSigned:IntType? { return UInt32(Int32.max) < self ? nil : IntType(self) }
}
extension UInt16:   POUInt {
    public typealias IntType = Int16
    public var asSigned:IntType? { return UInt16(Int16.max) < self ? nil : IntType(self) }
}
extension UInt8:    POUInt {
    public typealias IntType = Int8
    public var asSigned:IntType? { return UInt8(Int8.max) < self ? nil : IntType(self) }
}
extension UInt:     POUInt {
    public typealias IntType = Int
    public var asSigned:IntType? { return UInt(Int.max) < self ? nil : IntType(self) }
}

public typealias POSwiftInt = SignedIntegerType
///
/// Protocol-oriented signed integer.  All built-ins already conform to this.
///
/// For the sake of protocol-oriented programming,
/// consider extend this protocol first before extending each signed integer types.
///
public protocol POInt: POInteger, POSignedNumber, StringLiteralConvertible, CustomDebugStringConvertible {
    init(_:IntMax)
    ///
    /// The unsigned version of `self`
    ///
    typealias UIntType:POUInt           // its corresponding unsinged type
    init(_:UIntType)                    // capable of initializing from it
    var asUnsigned:UIntType? { get }    // able to convert to unsigned
}
public extension POInt {
    /// number of significant bits ==  sizeof(Self) * 8 - 1
    public static var precision:Int {
        return sizeof(Self) * 8 - 1
    }
    public static func addWithOverflow(lhs: Self, _ rhs: Self) -> (Self, overflow: Bool) {
        let (result, overflow) = Int.addWithOverflow(lhs.asInt!, rhs.asInt!)
        return (Self(result), overflow)
    }
    public static func subtractWithOverflow(lhs: Self, _ rhs: Self) -> (Self, overflow: Bool) {
        let (result, overflow) = Int.subtractWithOverflow(lhs.asInt!, rhs.asInt!)
        return (Self(result), overflow)
    }
    public static func multiplyWithOverflow(lhs: Self, _ rhs: Self) -> (Self, overflow: Bool) {
        let (result, overflow) = Int.multiplyWithOverflow(lhs.asInt!, rhs.asInt!)
        return (Self(result), overflow)
    }
    public static func divideWithOverflow(lhs: Self, _ rhs: Self) -> (Self, overflow: Bool) {
        let (result, overflow) = Int.divideWithOverflow(lhs.asInt!, rhs.asInt!)
        return (Self(result), overflow)
    }
    public static func remainderWithOverflow(lhs: Self, _ rhs: Self) -> (Self, overflow: Bool) {
        let (result, overflow) = Int.remainderWithOverflow(lhs.asInt!, rhs.asInt!)
        return (Self(result), overflow)
    }
    /// Default isSignMinus
    public var isSignMinus:Bool {
        return self < 0
    }
    /// Default toUIntMax
    public func toUIntMax()->UIntMax {
        return UIntMax(self.toIntMax())
    }
    // POInteger conformance
    public var asUInt64:UInt64? {
        let ix = self.toIntMax()
        return ix < 0 ? nil : UInt64(ix)
    }
    public var asUInt32:UInt32? {
        let ix = self.toIntMax()
        return ix < 0 ? nil : UInt32(ix)
    }
    public var asUInt16:UInt16? {
        let ix = self.toIntMax()
        return ix < 0 ? nil : UInt16(ix)
    }
    public var asUInt8:UInt8? {
        let ix = self.toIntMax()
        return ix < 0 ? nil : UInt8(ix)
    }
    public var asUInt:UInt? {
        let ix = self.toIntMax()
        return ix < 0 ? nil : UInt(ix)
    }
    public var asInt64:Int64? { return Int64(self.toIntMax()) }
    public var asInt32:Int32? { return Int32(self.toIntMax()) }
    public var asInt16:Int16? { return Int16(self.toIntMax()) }
    public var asInt8:Int8?   { return Int8(self.toIntMax()) }
    public var asInt:Int?     { return Int(self.toIntMax()) }
    public func toDouble()->Double { return Double(self.toIntMax()) }
    ///
    /// Returns the index of the most significant bit of `self`
    /// or `-1` if `self == 0`
    public var msbAt:Int {
        return self < 0 ? sizeof(Self) * 8 - 1 : self.toUIntMax().msbAt
    }
    ///
    /// Stringifies `self` with base `radix` which defaults to `10`
    ///
    public func toString(radix:Int = 10)-> String {
        return (self < 0 ? "-" : "") + self.abs.asUnsigned!.toString(radix)
    }
    // automagically CustomStringConvertible by defalut
    public var description:String {
        return self.toString()
    }
    // automagically CustomDebugStringConvertible
    public var debugDescription:String {
        return (self < 0 ? "-" : "+") + self.abs.asUInt64.debugDescription
    }
    /// init() with String. Handles `0x`, `0b`, and `0o`
    ///
    /// ought to be `init?` but that makes Swift 2.1 irate :-(
    public init(_ s:String, radix:Int = 10) {
        let si = s.startIndex
        let u = s[si] == "-" || s[si] == "+"
            ? UIntType(s[si.successor()..<s.endIndex], radix:radix)
            : UIntType(s, radix:radix)
        self.init(s[si] == "-" ? -Self(u) : +Self(u))
    }
    ///
    /// StringLiteralConvertible by Default
    public init(stringLiteral: String) {
        self.init(stringLiteral)
    }
    public init(unicodeScalarLiteral: String) {
        self.init(stringLiteral: "\(unicodeScalarLiteral)")
    }
    public init(extendedGraphemeClusterLiteral: String) {
        self.init(stringLiteral: extendedGraphemeClusterLiteral)
    }
    /// - returns: 
    ///   `lhs ** rhs` or `lhs ** rhs % mod` if `mod != 1`  (aka `modpow` or `powmod`)
    ///
    /// note only `rhs` must be an integer.
    /// also note it unconditinally returns `1` if `rhs < 1`
    /// for negative exponent, make lhs noninteger
    ///
    ///     pow(2,   -2) // 1
    ///     pow(2.0, -2) // 0.25
    public static func pow<L:POInt>(lhs:L, _ rhs:Self)->L {
        return rhs < 1 ? 1 : power(lhs, rhs){ L.multiplyWithOverflow($0, $1).0 }
    }
    /// - returns: `lhs ** rhs`
    public static func pow<L:POReal>(lhs:L, _ rhs:Self)->L {
        return L.pow(lhs, L(rhs.toDouble()))
    }
    /// true if self is power of 2
    public var isPowerOf2:Bool {
        return self.abs.asUnsigned!.isPowerOf2
    }
}
//
//public func &<I:POInt>(lhs:I, rhs:I)->I {
//    return I(lhs.toIntMax() & rhs.toIntMax())
//}
//public func |<I:POInt>(lhs:I, rhs:I)->I {
//    return I(lhs.toIntMax() | rhs.toIntMax())
//}
//public func ^<I:POInt>(lhs:I, rhs:I)->I {
//    return I(lhs.toIntMax() ^ rhs.toIntMax())
//}
//public func << <I:POInt>(lhs:I, rhs:I)->I {
//    return I(lhs.toIntMax() << rhs.toIntMax())
//}
//public func >> <I:POInt>(lhs:I, rhs:I)->I {
//    return I(lhs.toIntMax() << rhs.toIntMax())
//}
//
extension Int64:    POInt {
    public typealias UIntType = UInt64
    public var asUnsigned:UIntType? { return self < 0 ? nil : UIntType(self) }
}
extension Int32:    POInt {
    public typealias UIntType = UInt32
    public var asUnsigned:UIntType? { return self < 0 ? nil : UIntType(self) }
}
extension Int16:    POInt {
    public typealias UIntType = UInt16
    public var asUnsigned:UIntType? { return self < 0 ? nil : UIntType(self) }
}
extension Int8:     POInt {
    public typealias UIntType = UInt8
    public var asUnsigned:UIntType? { return self < 0 ? nil : UIntType(self) }
}
extension Int:      POInt {
    public typealias UIntType = UInt
    public var asUnsigned:UIntType? { return self < 0 ? nil : UIntType(self) }
}
