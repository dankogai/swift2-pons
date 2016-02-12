//
//  pofloat.swift
//  pons
//
//  Created by Dan Kogai on 2/4/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

public typealias POSwiftReal = FloatingPointType

public protocol POReal : POSignedNumber {
    init(_:Double)
    func toDouble()->Double
    var isInfinite:Bool  { get }
    var isNaN:Bool       { get }
    var isSignMinus:Bool { get }
    var isZero:Bool      { get }
    static var NaN:Self      { get }
    static var infinity:Self { get }
    var precision:Int { get }
    mutating func truncate(_:Int)->Self
}
public extension POReal {
    public var isFinite:Bool { return !isInfinite }
}
#if os(Linux)
    import Glibc
#else
    import Darwin
#endif
public protocol POFloat : POReal {
    // static var EPSILON:Self { get }
}
// public protocol POElementaryFunctional : POReal {}
extension POReal {
    #if os(Linux)
    public static func sqrt(x:Self)->Self   { return Self(Glibc.sqrt(x.toDouble())) }
    public static func hypot(x:Self, _ y:Self)->Self { return Self(Glibc.hypot(x.toDouble(), y.toDouble())) }
    public static func log(x:Self)->Self    { return Self(Glibc.log(x.toDouble())) }
    public static func exp(x:Self)->Self    { return Self(Glibc.exp(x.toDouble())) }
    public static func pow(x:Self, _ y:Self)->Self  { return Self(Glibc.pow(x.toDouble(), y.toDouble())) }
    public static func cos(x:Self)->Self    { return Self(Glibc.cos(x.toDouble())) }
    public static func sin(x:Self)->Self    { return Self(Glibc.sin(x.toDouble())) }
    public static func tan(x:Self)->Self    { return Self(Glibc.tan(x.toDouble())) }
    public static func atan2(y:Self, _ x:Self)->Self { return Self(Glibc.atan2(y.toDouble(), x.toDouble())) }
    public static func acos(x:Self)->Self   { return Self(Glibc.acos(x.toDouble())) }
    public static func asin(x:Self)->Self   { return Self(Glibc.asin(x.toDouble())) }
    public static func atan(x:Self)->Self   { return Self(Glibc.atan(x.toDouble())) }
    public static func cosh(x:Self)->Self   { return Self(Glibc.cosh(x.toDouble())) }
    public static func sinh(x:Self)->Self   { return Self(Glibc.sinh(x.toDouble())) }
    public static func tanh(x:Self)->Self   { return Self(Glibc.tanh(x.toDouble())) }
    public static func acosh(x:Self)->Self  { return Self(Glibc.acosh(x.toDouble())) }
    public static func asinh(x:Self)->Self  { return Self(Glibc.asinh(x.toDouble())) }
    public static func atanh(x:Self)->Self  { return Self(Glibc.atanh(x.toDouble())) }
    #else
    // public static func sqrt(x:Self)->Self   { return Self(Darwin.sqrt(x.toDouble())) }
    /// - returns: square root of `x` to precision `precision`
    public static func sqrt(x:Self, precision:Int = 64)->Self {
        if let dx = x as? Double { return Self(Double.sqrt(dx)) }
        if x < 0  { return Self.NaN }
        if x == 0 { return 0 }
        if x == 1 { return 1 }
        let px = Swift.max(x.precision, precision)
        let iter = max((px / 1.0.precision).msbAt + 1, 1)
        var r0 = Self(Darwin.sqrt(x.toDouble()))
        var r = r0
        // print("\(__FILE__):\(__LINE__) iter=\(iter)")
        for _ in 0...iter {
            r = (x/r0 + r0) / 2
            if r0 == r { break }
            r.truncate(px * 2)
            r0 = r
        }
        return r.truncate(px)

    }
    public static func hypot(x:Self, _ y:Self, precision:Int=64)->Self {
        return Self.sqrt(x * x + y * y, precision:precision)
    }
    // public static func exp(x:Self)->Self    { return Self(Darwin.exp(x.toDouble())) }
    public static func exp(x:Self, precision:Int = 64)->Self {
        if let dx = x as? Double { return Self(Double.exp(dx)) }
        if x == 0 { return 1 }
        let ax = x < 0 ? -x : x
        let px = Swift.max(x.precision, precision)
        let iax = Int(ax.toIntMax())
        let fax = ax - Self(iax)
        var eiax = Self(1)
        if iax != 0 {
            let e:Self = {
                var (r, t):(Self, Self) = (1, 1)
                for i in 1...px {
                    t /= Self(i)
                    r += t
                    if px <= t.precision { break }
                }
                return r
            }()
            eiax = Int.power(e, iax, op:*)
            eiax.truncate(px * 2)
            if fax == 0 { return x < 0 ? (1 / eiax) : eiax }
        }
        var efax:Self = 1
        var t:Self = 1
        let epsilon = Double.ldexp(1.0, -px)
        // print("epsilon=\(epsilon.toDouble()), fax=\(fax.toDouble())")
        for i in 1...px {
            // print("i=\(i), epsilon=\(epsilon), t.precision=\(t.toDouble())")
            t *= fax / Self(i)
            t.truncate(px + 1)
            efax += t
            efax.truncate(px * 2)
            if t.toDouble() < epsilon { break }
        }
        var r = x < 0 ? 1 / (eiax * efax) : (eiax * efax)
        r.truncate(px)
        return r
    }
    /// ![](https://upload.wikimedia.org/math/1/7/5/17534a763ff4b0fd87ce62556ebcc3d7.png)
    public static func log(x:Self, precision:Int = 64)->Self {
        if let dx = x as? Double { return Self(Double.log(dx)) }
        if x < 0  { return Self.NaN }
        if x == 0 { return 1 }
        let px = Swift.max(x.precision, precision)
        var t = (x - 1) / (x + 1)
        let t2 = t * t
        var r:Self = t
        let epsilon = Double.ldexp(1.0, -px)
        for i in 1...px {
            // print("i=\(i), epsilon=\(epsilon), r=\(r.toDouble())")
            t *= t2
            t.truncate(px + 1)
            r += t / Self(2*i + 1)
            r.truncate(px * 2)
            if t.toDouble() < epsilon { break }
        }
        return 2 * r.truncate(px)
    }
    public static func pow(x:Self, _ y:Self)->Self  { return Self(Darwin.pow(x.toDouble(), y.toDouble())) }
    public static func cos(x:Self)->Self    { return Self(Darwin.cos(x.toDouble())) }
    public static func sin(x:Self)->Self    { return Self(Darwin.sin(x.toDouble())) }
    public static func tan(x:Self)->Self    { return Self(Darwin.tan(x.toDouble())) }
    public static func atan2(y:Self, _ x:Self)->Self { return Self(Darwin.atan2(y.toDouble(), x.toDouble())) }
    public static func acos(x:Self)->Self   { return Self(Darwin.acos(x.toDouble())) }
    public static func asin(x:Self)->Self   { return Self(Darwin.asin(x.toDouble())) }
    public static func atan(x:Self)->Self   { return Self(Darwin.atan(x.toDouble())) }
    public static func cosh(x:Self)->Self   { return Self(Darwin.cosh(x.toDouble())) }
    public static func sinh(x:Self)->Self   { return Self(Darwin.sinh(x.toDouble())) }
    public static func tanh(x:Self)->Self   { return Self(Darwin.tanh(x.toDouble())) }
    public static func acosh(x:Self)->Self  { return Self(Darwin.acosh(x.toDouble())) }
    public static func asinh(x:Self)->Self  { return Self(Darwin.asinh(x.toDouble())) }
    public static func atanh(x:Self)->Self  { return Self(Darwin.atanh(x.toDouble())) }
    #endif
    public static var PI:Self       { return Self(M_PI) }
    public static var E:Self        { return Self(M_E) }
    public static var LN2:Self      { return Self(M_LN2) }
    public static var LN10:Self     { return Self(M_LN10) }
    public static var LOG2E:Self    { return Self(M_LOG2E) }
    public static var LOG10E:Self   { return Self(M_LOG10E) }
    public static var SQRT1_2:Self  { return Self(M_SQRT1_2) }
    public static var SQRT2:Self    { return Self(M_SQRT2) }
}
extension Double : POFloat {
    public func toDouble()->Double { return self }
    public func toIntMax()->IntMax { return IntMax(self) }
    /// number of significant bits == 52
    public static let precision = 52
    public var precision:Int { return Double.precision }
    #if os(Linux)
    public static func frexp(d:Double)->(Double, Int) {
        // return Glibc.frexp(d)
        var e:Int32 = 0
        let m = Glibc.frexp(d, &e)
        return (m, Int(e))
    }
    public static func ldexp(m:Double, _ e:Int)->Double {
        // return Glibc.ldexp(m, e)
        return Glibc.ldexp(m, Int32(e))
    }
    #else
    public static func frexp(d:Double)->(Double, Int)   { return Darwin.frexp(d) }
    public static func ldexp(m:Double, _ e:Int)->Double { return Darwin.ldexp(m, e) }
    public static func sqrt(x:Double, precision:Int=0)->Double { return Darwin.sqrt(x) }
    public static func hypot(x:Double, _ y:Double, precision:Int=0)->Double { return Darwin.hypot(x, y) }
    public static func exp(x:Double, precision:Int=0)->Double   { return Darwin.exp(x) }
    public static func log(x:Double, precision:Int=0)->Double   { return Darwin.log(x) }
    #endif
    public func truncate(bits:Int)->Double {
        return self
    }
}
extension Float : POFloat {
    public func toDouble()->Double { return Double(self) }
    public func toIntMax()->IntMax { return IntMax(self) }
    /// number of significant bits == 23
    public static let precision = 23
    public var precision:Int { return Float.precision }
    public func truncate(bits:Int)->Float {
        return self
    }
}

