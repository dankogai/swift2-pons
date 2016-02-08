//
//  pointeger.swift
//  pons
//
//  Created by Dan Kogai on 2/4/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

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
}
// give away &op
public func &+<I:POInteger>(lhs:I, rhs:I)->I {
    return I.addWithOverflow(lhs, rhs).0
}
public func &-<I:POInteger>(lhs:I, rhs:I)->I {
    return I.subtractWithOverflow(lhs, rhs).0
}
public func &*<I:POInteger>(lhs:I, rhs:I)->I {
    return I.multiplyWithOverflow(lhs, rhs).0
}
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
        self.init(UInt(_builtinIntegerLiteral: _builtinIntegerLiteral))
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
    public init(_ d:Double) { self.init(IntMax(d)) }
    public func toDouble()->Double { return Double(self.toIntMax()) }
    /// default initializers just Int()s the argument.
    /// in practice you should override them, especially U?Int64 and Double
    public init(_ v:UInt64) { self.init(Int(v)) }       //  override this for the best result
    public init(_ v:UInt32) { self.init(v.toUIntMax()) }
    public init(_ v:UInt16) { self.init(v.toUIntMax()) }
    public init(_ v:UInt8)  { self.init(v.toUIntMax()) }
    public init(_ v:UInt)   { self.init(v.toUIntMax()) }
    public init(_ v:Int64)  { self.init(Int(v)) }       // override this for the best result
    public init(_ v:Int32)  { self.init(v.toIntMax()) }
    public init(_ v:Int16)  { self.init(v.toIntMax()) }
    public init(_ v:Int8)   { self.init(v.toIntMax()) }
    /// give away these converters
    public var asUInt64:UInt64  { return UInt64(self.toIntMax()) }
    public var asUInt32:UInt32  { return UInt32(self.toIntMax()) }
    public var asUInt16:UInt16  { return UInt16(self.toIntMax()) }
    public var asUInt8:UInt8    { return UInt8(self.toIntMax()) }
    public var asUInt:UInt      { return UInt(self.toIntMax()) }
    public var asInt64:Int64    { return Int64(self.toIntMax()) }
    public var asInt32:Int32    { return Int32(self.toIntMax()) }
    public var asInt16:Int16    { return Int16(self.toIntMax()) }
    public var asInt8:Int8      { return Int8(self.toIntMax()) }
    public var asInt:Int        { return Int(self.toIntMax()) }
    public var asDouble:Double  { return self.toDouble() }
    public var asFloat:Float    { return Float(self.toDouble()) }
    /// default implementation.  you should override it
    public static func divmod(lhs:Self, _ rhs:Self)->(Self, Self) {
        return (lhs / rhs, lhs % rhs)
    }
}
///
/// Placeholder for utility functions and values
///
public class POUtil {
    public static let int2char = Array("0123456789abcdefghijklmnopqrstuvwxyz".characters)
    public static let char2int:[Character:Int] = {
        var result = [Character:Int]()
        for i in 0..<int2char.count {
            result[int2char[i]] = i
        }
        return result
    }()
}
///
/// Protocol-oriented unsigned integer.  All built-ins already conform to this.
///
/// For the sake of protocol-oriented programming,
/// consider extend this protocol first before extending each unsigned integer type.
///
public protocol POUInt: POInteger, StringLiteralConvertible, CustomDebugStringConvertible {
    func toUIntMax()->UIntMax
    typealias IntType:POSignedNumber    // its correspoinding singed type
    //init(_:IntType)         // must be capable of initializing from it
    var asSigned:IntType { get }
}
public extension POUInt {
    /// number of significant bits ==  sizeof(Self) * 8
    public static var precision:Int {
        return sizeof(Self) * 8
    }
    ///
    /// Returns the index of the most significant bit of `self`
    /// or `-1` if `self == 0`
    public var msbAt:Int { return self.toUIntMax().msbAt }
    // overrides POInteger implementations
    public var asUInt64:UInt64  { return UInt64(self.toUIntMax()) }
    public var asUInt32:UInt32  { return UInt32(self.toUIntMax()) }
    public var asUInt16:UInt16  { return UInt16(self.toUIntMax()) }
    public var asUInt8:UInt8    { return UInt8(self.toUIntMax()) }
    public var asUInt:UInt      { return UInt(self.toUIntMax()) }
    public var asDouble:Double  { return Double(self.toUIntMax()) }
    public var asFloat:Float    { return Float(self.toUIntMax()) }
    // overrides POInteger IntegerLiteralConvertible
    public init(integerLiteral:UInt) {
        self.init(integerLiteral.toUIntMax())
    }
    ///
    /// `self.toString()` uses this to extract digits
    ///
    public static func divmod8(lhs:Self, _ rhs:Int8)->(Self, Int) {
        let denom = Self(rhs)
        return (lhs / denom, (lhs % denom).asInt)
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
}
extension UInt64:   POUInt {
    public typealias IntType = Int64
    public var msbAt:Int {
        return self <= UInt64(UInt32.max)
            ? UInt32(self).msbAt
            : UInt32(self >> 32).msbAt + 32
    }
    public var asSigned:IntType { return IntType(self) }
}
extension UInt32:   POUInt {
    public typealias IntType = Int32
    public var asSigned:IntType { return IntType(self) }
    public var msbAt:Int {
        return Double.frexp(Double(self)).1 - 1
    }
}
extension UInt16:   POUInt {
    public typealias IntType = Int16
    public var asSigned:IntType { return IntType(self) }
}
extension UInt8:    POUInt {
    public typealias IntType = Int8
    public var asSigned:IntType { return IntType(self) }
}
extension UInt:     POUInt {
    public typealias IntType = Int
    public var asSigned:IntType { return IntType(self) }
}
///
/// Protocol-oriented signed integer.  All built-ins already conform to this.
///
/// For the sake of protocol-oriented programming,
/// consider extend this protocol first before extending each signed integer types.
///
public protocol POInt:  POInteger, POSignedNumber, StringLiteralConvertible, CustomDebugStringConvertible {
    ///
    /// The unsigned version of `self`
    ///
    typealias UIntType:POUInt       // its corresponding unsinged type
    init(_:UIntType)                // capable of initializing from it
    var asUnsigned:UIntType { get }  // able to convert to unsigned
}
public extension POInt {
    /// number of significant bits ==  sizeof(Self) * 8 - 1
    public static var precision:Int {
        return sizeof(Self) * 8 - 1
    }
    /// Default isSignMinus
    public var isSignMinus:Bool { return self < 0 }
    /// Default toUIntMax
    public func toUIntMax()->UIntMax {
        return UIntMax(self.toIntMax())
    }
    ///
    /// Returns the index of the most significant bit of `self`
    /// or `-1` if `self == 0`
    public var msbAt:Int {
        return self < 0 ? sizeof(Self) * 8 - 1 : self.toUIntMax().msbAt
    }
    ///
    /// absolute value of `self`
    ///
    public var abs:Self { return Swift.abs(self) }
    ///
    /// Stringifies `self` with base `radix` which defaults to `10`
    ///
    public func toString(radix:Int = 10)-> String {
        return (self < 0 ? "-" : "") + self.abs.asUInt64.toString(radix)
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
        if rhs < 1 {
            fatalError("negative exponent unsupported")
        }
        var r = lhs
        var t = lhs, n = rhs - 1
        while n > 0 {
            if n & 1 == 1 {
                r = op(r, t)
            }
            n >>= 1
            t = op(t, t)
        }
        return r
    }
    ///
    /// Note only `rhs` must be integer
    ///
    public static func pow<L:POUInt>(lhs:L, _ rhs:Self)->L {
        return rhs < 1 ? 1 : power(lhs, rhs, op:&*)
    }
    public static func pow<L:POInt>(lhs:L, _ rhs:Self)->L {
        return rhs < 1 ? 1 :  power(lhs, rhs, op:&*)
    }
    public static func pow<L:POReal>(lhs:L, _ rhs:Self)->L {
        return L(Double.pow(lhs.toDouble(), rhs.asDouble))
    }
}
extension Int64:    POInt {
    public typealias UIntType = UInt64
    public var asUnsigned:UIntType { return UIntType(self) }
}
extension Int32:    POInt {
    public typealias UIntType = UInt32
    public var asUnsigned:UIntType { return UIntType(self) }
}
extension Int16:    POInt {
    public typealias UIntType = UInt16
    public var asUnsigned:UIntType { return UIntType(self) }
}
extension Int8:     POInt {
    public typealias UIntType = UInt8
    public var asUnsigned:UIntType { return UIntType(self) }
}
extension Int:      POInt {
    public typealias UIntType = UInt
    public var asUnsigned:UIntType { return UIntType(self) }
}
