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
public extension POReal {
    #if os(Linux)
    public static func pow(x:Self, _ y:Self, precision:Int = 64)->Self  { return Self(Glibc.pow(x.toDouble(), y.toDouble())) }
    public static func cos(x:Self, precision:Int = 64)->Self    { return Self(Glibc.cos(x.toDouble())) }
    public static func sin(x:Self, precision:Int = 64)->Self    { return Self(Glibc.sin(x.toDouble())) }
    public static func tan(x:Self, precision:Int = 64)->Self    { return Self(Glibc.tan(x.toDouble())) }
    public static func acos(x:Self, precision:Int = 64)->Self   { return Self(Glibc.acos(x.toDouble())) }
    public static func asin(x:Self, precision:Int = 64)->Self   { return Self(Glibc.asin(x.toDouble())) }
    public static func cosh(x:Self, precision:Int = 64)->Self   { return Self(Glibc.cosh(x.toDouble())) }
    public static func sinh(x:Self, precision:Int = 64)->Self   { return Self(Glibc.sinh(x.toDouble())) }
    public static func tanh(x:Self, precision:Int = 64)->Self   { return Self(Glibc.tanh(x.toDouble())) }
    public static func acosh(x:Self, precision:Int = 64)->Self  { return Self(Glibc.acosh(x.toDouble())) }
    public static func asinh(x:Self, precision:Int = 64)->Self  { return Self(Glibc.asinh(x.toDouble())) }
    public static func atanh(x:Self, precision:Int = 64)->Self  { return Self(Glibc.atanh(x.toDouble())) }
    #else
    public static func pow(x:Self, _ y:Self, precision:Int = 64)->Self  { return Self(Darwin.pow(x.toDouble(), y.toDouble())) }
    public static func cos(x:Self, precision:Int = 64)->Self    { return Self(Darwin.cos(x.toDouble())) }
    public static func sin(x:Self, precision:Int = 64)->Self    { return Self(Darwin.sin(x.toDouble())) }
    public static func tan(x:Self, precision:Int = 64)->Self    { return Self(Darwin.tan(x.toDouble())) }
    public static func acos(x:Self, precision:Int = 64)->Self   { return Self(Darwin.acos(x.toDouble())) }
    public static func asin(x:Self, precision:Int = 64)->Self   { return Self(Darwin.asin(x.toDouble())) }
    public static func cosh(x:Self, precision:Int = 64)->Self   { return Self(Darwin.cosh(x.toDouble())) }
    public static func sinh(x:Self, precision:Int = 64)->Self   { return Self(Darwin.sinh(x.toDouble())) }
    public static func tanh(x:Self, precision:Int = 64)->Self   { return Self(Darwin.tanh(x.toDouble())) }
    public static func acosh(x:Self, precision:Int = 64)->Self  { return Self(Darwin.acosh(x.toDouble())) }
    public static func asinh(x:Self, precision:Int = 64)->Self  { return Self(Darwin.asinh(x.toDouble())) }
    public static func atanh(x:Self, precision:Int = 64)->Self  { return Self(Darwin.atanh(x.toDouble())) }
    #endif
    ////
    public static func getSetConstant(
        name:String, _ arg:Self, _ precision:Int, setter:(Self, Int)->Self
        )->Self
    {
        let key = "\(Self.self).\(name)(\(arg), precision:\(precision))"
        // print("\(__FILE__):\(__LINE__) fetching \(key)")
        if let value = POUtil.constants[key] {
            return value as! Self
        }
        let value = setter(arg, precision)
        // print("\(__FILE__):(__LINE__) storing \(key) => \(value)")
        POUtil.constants[key] = value
        return value
    }
    // public static func sqrt(x:Self)->Self   { return Self(Darwin.sqrt(x.toDouble())) }
    /// - returns: square root of `x` to precision `precision`
    public static func sqrt(x:Self, precision:Int = 64)->Self {
        if let dx = x as? Double { return Self(Double.sqrt(dx)) }
        if x < 0  { return Self.NaN }
        if x == 0 { return 0 }
        if x.isInfinite { return Self.infinity }
        let px = Swift.max(x.precision, precision)
        let iter = max(px.msbAt + 1, 1)
        let inner_sqrt:(Self,Int)->Self = { x , px in
            var r0 = x < 1 ? 1 : x
            var r = r0
            // return r.truncate(px)
            // print("\(__FILE__):\(__LINE__): px=\(px), iter=\(iter)")
            for _ in 0...iter {
                r = (x/r0 + r0) / 2
                if r == r0 { break }
                r.truncate(px * 2)
                r0 = r
            }
            return r
        }
        if x == 2 {
            return getSetConstant("sqrt", 2, px, setter:inner_sqrt)
        }
        var r = inner_sqrt(x, px)
        return r.truncate(px)
    }
    public static func hypot(x:Self, _ y:Self, precision:Int=64)->Self {
        if let dx = x as? Double { return Self(Double.hypot(dx, y as! Double)) }
        return Self.sqrt(x * x + y * y, precision:precision)
    }
    public static func exp(x:Self, precision:Int = 64)->Self {
        if let dx = x as? Double { return Self(Double.exp(dx)) }
        if x.isZero { return 1 }
        let px = Swift.max(x.precision, precision)
        let ax = x < 0 ? -x : x
        let ix = ax.toIntMax().asInt!
        let fx = ax - Self(ix)
        let epsilon = Self(Double.ldexp(1.0, -px))
        // print("\(Self.self).exp(\(x), precision:\(precision)):ax=\(ax), ix=\(ix), fx=\(fx)")
        let inner_exp:(Self, Int)->Self = { x, px in
            var (r, t) = (Self(1), Self(1))
            for i in 1...px {
                t *= x / Self(i)
                t.truncate(px * 2)
                r += t
                r.truncate(px * 2)
                if t < epsilon { break }
                // print("\(Self.self).inner_exp(\(x)):i=\(i), x=\(x.toDouble()),r=\(r.toDouble())")
            }
            return r
        }
        let e = getSetConstant("exp", Self(1), px, setter:inner_exp)
        //let ir = ix == 0 ? Self(1) : Int.power(inner_exp(1), ix, op:*)
        let ir = ix == 0 ? Self(1) : Int.power(e, ix, op:*)
        let fr = fx == 0 ? Self(1) : inner_exp(fx, px)
        var r = ir * fr
        //print("ir=\(ir.toDouble()), fr=\(fr.toDouble()), r=\(r.toDouble())")
        return x.isSignMinus ? 1/r.truncate(px) : r.truncate(px)
    }
    /// ![](https://upload.wikimedia.org/math/1/7/5/17534a763ff4b0fd87ce62556ebcc3d7.png)
    public static func log(x:Self, precision:Int = 64)->Self {
        if let dx = x as? Double { return Self(Double.log(dx)) }
        if x.isSignMinus { return Self.NaN }
        if x.isZero      { return -Self.infinity }
        if x == 1        { return 0 }
        let px = Swift.max(x.precision, precision)
        let inner_log:(Self, Int)->Self = { x , px in
            var t = (x - 1)/(x + 1)
            if x < 1 { t = -t }
            let t2 = t * t
            var r:Self = t
            let epsilon = Self(Double.ldexp(1.0, -px))
            for i in 1...px*2 {
                t *= t2
                t.truncate(px * 2)
                r += t / Self(2*i + 1)
                // print("POReal#log: i=\(i), px=\(px), t=\(t.toDouble()), r=\(r.toDouble())")
                r.truncate(px * 2)
                if t < epsilon { break }
            }
            return 2 * (x < 1 ? -r : r)
        }
        let ln2 = getSetConstant("log", 2, px, setter:inner_log)
        let il = x.toIntMax().msbAt
        let fl = x / Self(Double.ldexp(1.0, il))
        let ir = il == 0 ? 0 : ln2 * Self(il)
        let fr = fl == 0 ? 0 : inner_log(fl, px)
        var r =  ir + fr
        //print("ln(\(x.toDouble())) =~ ln(\(Double.ldexp(1.0,il)))+ln(\(fl.toDouble()))"
        //    + " = \(ir.toDouble())+\(fr.toDouble()) = \(r.toDouble())")
        return r.truncate(px)
    }
    /// Arc tangent
    ///
    /// https://en.wikipedia.org/wiki/Inverse_trigonometric_functions#Infinite_series
    ///
    /// ![](https://upload.wikimedia.org/math/8/2/a/82a9938b7482d8d2ac5b2d7f3bce11fe.png)
    public static func atan(x:Self, precision:Int = 64)->Self {
        // return Self(Darwin.atan(x.toDouble()))
        if let dx = x as? Double { return Self(Double.atan(dx)) }
        let px = Swift.max(x.precision, precision)
        let epsilon = Self(Double.ldexp(1.0, -px))
        let inner_atan:(Self, Int)->Self = { x , px in
            let x2 = x*x
            let x2p1 = 1 + x2
            var (t, r) = (Self(1), Self(1))
            for i in 1...px*4 {
                t *= 2 * Self(i) * x2 / (Self(2 * i + 1) * x2p1)
                t.truncate(px * 2)
                r += t
                // print("POReal#log: i=\(i), px=\(px), t=\(t.toDouble()), r=\(r.toDouble())")
                r.truncate(px * 2)
                if t < epsilon { break }
            }
            return r * x / x2p1
        }
        let pi_4 = getSetConstant("atan", 1, px, setter:{_, px in pi(px)/4 })
        if x == 1 { return pi_4 }
        let ax = x < 0 ? -x : x
        var r = ax < 1 ? inner_atan(ax, px) : 2 * pi_4 - inner_atan(1/ax, px)
        return x < 0 ? -r.truncate(px) : r.truncate(px)
    }
    public static func atan2(y:Self, _ x:Self, precision:Int = 64)->Self {
        if let dy = y as? Double { return Self(Double.atan2(dy, x as! Double)) }
        let px = Swift.max(x.precision, precision)
        if x.isNaN || y.isNaN { return Self.NaN }
        if x.isZero || y.isZero || x.isInfinite || y.isInfinite {   // let us consult Double.atan2 this case
            switch Double.atan2(y.toDouble(), x.toDouble()) {
            case   +Double.PI/4 : return +pi(px)/4
            case   -Double.PI/4 : return -pi(px)/4
            case   +Double.PI/2 : return +pi(px)/2
            case   -Double.PI/2 : return -pi(px)/2
            case +3*Double.PI/4 : return +3*pi(px)/4
            case -3*Double.PI/4 : return -3*pi(px)/4
            case   +Double.PI   : return +pi(px)
            case   -Double.PI   : return -pi(px)
            case let d where d.isSignMinus : return -0
            default:                         return +0
            }
        }
        if x < 0 {
            return atan(y/x, precision:px) + (y < 0 ? -pi(px) : +pi(px))
        } else {
            return atan(y/x, precision:px)
        }
    }
    ///
    /// https://en.wikipedia.org/wiki/Bellard%27s_formula
    ///
    /// ![](https://upload.wikimedia.org/math/d/b/f/dbf2d4355c108f6b3388985be4976799.png)
    public static func pi(px:Int = 64, verbose:Bool=false)->Self {
        if Self.self == Double.self { return Self(Double.PI) }
        return 4 * getSetConstant("atan", 1, px) { _, px in
            let epsilon = Self(Double.ldexp(1.0, -px))
            var p64 = Self(0)
            for i in 0..<px {
                var t = Self(0)
                t -= Self(1<<5) /  Self(4 * i + 1)
                t -= Self(1<<0) /  Self(4 * i + 3)
                t += Self(1<<8) / Self(10 * i + 1)
                t -= Self(1<<6) / Self(10 * i + 3)
                t -= Self(1<<2) / Self(10 * i + 5)
                t -= Self(1<<2) / Self(10 * i + 7)
                t += Self(1<<0) / Self(10 * i + 9)
                if 0 < i { t /= Int.power(Self(2), 10 * i, op:*) }
                p64 += i & 1 == 1 ? -t : t
                if verbose {
                    print("\(__FILE__):\(__LINE__): iter = \(i); "
                        + "p64.precision = \(p64.precision), t.precision = \(t.precision);")
                }
                if t < epsilon { break }
            }
            return p64.truncate(px) / Self(1<<8)
        }
    }
    public static var PI:Self       { return Self(M_PI) }
    public static var LN2:Self      { return Self(M_LN2) }
    public static var LN10:Self     { return Self(M_LN10) }
    public static var LOG2E:Self    { return Self(M_LOG2E) }
    public static var LOG10E:Self   { return Self(M_LOG10E) }
    public static var SQRT1_2:Self  { return Self(M_SQRT1_2) }
    public static var SQRT2:Self    { return Self(M_SQRT2) }
}
public extension POUtil {
    public static var constants = [String:Any]()
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
    //
    public static func sqrt(x:Double, precision:Int=52)->Double     { return Glibc.sqrt(x) }
    public static func hypot(x:Double, _ y:Double, precision:Int=52)->Double { return Glibc.hypot(x, y) }
    public static func exp(x:Double, precision:Int=52)->Double      { return Glibc.exp(x) }
    public static func log(x:Double, precision:Int=52)->Double      { return Glibc.log(x) }
    public static func log10(x:Double, precision:Int=52)->Double    { return Glibc.log10(x) }
    public static func pow(x:Double, _ y:Double, precision:Int=52)->Double  { return Glibc.pow(x, y) }
    public static func cos(x:Double, precision:Int=52)->Double      { return Glibc.cos(x) }
    public static func sin(x:Double, precision:Int=52)->Double      { return Glibc.sin(x) }
    public static func tan(x:Double, precision:Int=52)->Double      { return Glibc.tan(x) }
    public static func acos(x:Double, precision:Int=52)->Double     { return Glibc.acos(x) }
    public static func asin(x:Double, precision:Int=52)->Double     { return Glibc.asin(x) }
    public static func atan(x:Double, precision:Int=52)->Double     { return Glibc.atan(x) }
    public static func atan2(y:Double, _ x:Double, precision:Int=52)->Double { return Glibc.atan2(y, x) }
    public static func cosh(x:Double, precision:Int=52)->Double     { return Glibc.cosh(x) }
    public static func sinh(x:Double, precision:Int=52)->Double     { return Glibc.sinh(x) }
    public static func tanh(x:Double, precision:Int=52)->Double     { return Glibc.tanh(x) }
    public static func acosh(x:Double, precision:Int=52)->Double    { return Glibc.acosh(x) }
    public static func asinh(x:Double, precision:Int=52)->Double    { return Glibc.asinh(x) }
    public static func atanh(x:Double, precision:Int=52)->Double    { return Glibc.atanh(x) }
    #else
    public static func frexp(d:Double)->(Double, Int)   { return Darwin.frexp(d) }
    public static func ldexp(m:Double, _ e:Int)->Double { return Darwin.ldexp(m, e) }
    //
    public static func sqrt(x:Double, precision:Int=52)->Double     { return Darwin.sqrt(x) }
    public static func hypot(x:Double, _ y:Double, precision:Int=52)->Double { return Darwin.hypot(x, y) }
    public static func exp(x:Double, precision:Int=52)->Double      { return Darwin.exp(x) }
    public static func log(x:Double, precision:Int=52)->Double      { return Darwin.log(x) }
    public static func log10(x:Double, precision:Int=52)->Double     { return Darwin.log10(x) }
    public static func pow(x:Double, _ y:Double, precision:Int=52)->Double  { return Darwin.pow(x, y) }
    public static func cos(x:Double, precision:Int=52)->Double      { return Darwin.cos(x) }
    public static func sin(x:Double, precision:Int=52)->Double      { return Darwin.sin(x) }
    public static func tan(x:Double, precision:Int=52)->Double      { return Darwin.tan(x) }
    public static func acos(x:Double, precision:Int=52)->Double     { return Darwin.acos(x) }
    public static func asin(x:Double, precision:Int=52)->Double     { return Darwin.asin(x) }
    public static func atan(x:Double, precision:Int=52)->Double     { return Darwin.atan(x) }
    public static func atan2(y:Double, _ x:Double, precision:Int=52)->Double { return Darwin.atan2(y, x) }
    public static func cosh(x:Double, precision:Int=52)->Double     { return Darwin.cosh(x) }
    public static func sinh(x:Double, precision:Int=52)->Double     { return Darwin.sinh(x) }
    public static func tanh(x:Double, precision:Int=52)->Double     { return Darwin.tanh(x) }
    public static func acosh(x:Double, precision:Int=52)->Double    { return Darwin.acosh(x) }
    public static func asinh(x:Double, precision:Int=52)->Double    { return Darwin.asinh(x) }
    public static func atanh(x:Double, precision:Int=52)->Double    { return Darwin.atanh(x) }
    #endif
    public func truncate(bits:Int)->Double {
        return self
    }
    public static var PI      = M_PI
    public static var E       = M_E
    public static var LN2     = M_LN2
    public static var LN10    = M_LN10
    public static var LOG2E   = M_LOG2E
    public static var LOG10E  = M_LOG10E
    public static var SQRT1_2 = M_SQRT1_2
    public static var SQRT2   = M_SQRT2
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

