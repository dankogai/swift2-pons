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
public protocol POInteger : PONumber, IntegerArithmeticType, IntegerType, BitwiseOperationsType {
    func <<(_:Self,_:Self)->Self
    func <<=(inout _:Self, _:Self)
    func >>(_:Self,_:Self)->Self
    func >>=(inout _:Self, _:Self)
    // init?(_:String, radix:Int)
}
public extension POInteger {
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
    ///
    /// Integer power.  Note only `rhs` must be integer
    ///
    public static func pow<L:PONumber>(lhs: L, _ rhs:Self)->L {
        guard 0 <= rhs else {
            fatalError("negative exponent not supported")
        }
        if lhs == 0 { return 1 }
        if rhs == 1 { return lhs }
        // cf. https://en.wikipedia.org/wiki/Exponentiation_by_squaring
        var r = L(1)
        var t = lhs, n = rhs
        while n > Self(0) {
            if n & 1 == 1 {
                r = r * t
            }
            n >>= Self(1); t = t * t
        }
        return r
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
public protocol POUInt: POInteger, UnsignedIntegerType, StringLiteralConvertible, CustomDebugStringConvertible {
    // typealias IntType:POInt // its correspoinding singed type
    // init(_:IntType)         // must be capable of initializing from it
}
public extension POUInt {
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
    // public typealias IntType = Int64
    public var msbAt:Int {
        return self <= UInt64(UInt32.max)
            ? UInt32(self).msbAt
            : UInt32(self >> 32).msbAt + 32
    }
}
extension UInt32:   POUInt {
    // public typealias IntType = Int32
    public var msbAt:Int {
        return Double.frexp(Double(self)).1 - 1
    }
}
extension UInt16:   POUInt {
    // public typealias IntType = Int16
}
extension UInt8:    POUInt {
    // public typealias IntType = Int8
}
extension UInt:     POUInt {
    // public typealias IntType = Int
}
///
/// Protocol-oriented signed integer.  All built-ins already conform to this.
///
/// For the sake of protocol-oriented programming,
/// consider extend this protocol first before extending each signed integer types.
///
public protocol POInt:  POInteger, POSignedNumber,
                        SignedIntegerType, StringLiteralConvertible, CustomDebugStringConvertible {
    ///
    /// The unsigned version of `self`
    ///
    typealias UIntType:POUInt  // its correspoinding unsinged type
    init(_:UIntType)           // must be capable of initializing from it
}
public extension POInt {
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
extension Int64:    POInt {
    public typealias UIntType = UInt64
}
extension Int32:    POInt {
    public typealias UIntType = UInt32
}
extension Int16:    POInt {
    public typealias UIntType = UInt16
}
extension Int8:     POInt {
    public typealias UIntType = UInt8
}
extension Int:      POInt {
    public typealias UIntType = UInt
}
