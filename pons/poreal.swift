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
    // public static func sqrt(x:Self)->Self   { return Self(Darwin.sqrt(x.toDouble())) }
    /// - returns: square root of `x` to precision `precision`
    public static func sqrt(x:Self, precision:Int = 64)->Self {
        if let d = x as? Double { return Self(Double.sqrt(d)) }
        if x < 0 { return Self.NaN }
        if x.isInfinite { return Self.infinity }
        let px = Swift.max(x.precision, precision)
        let typename = "\(Self.infinity.dynamicType)"
        typealias PC = POUtil.Constants
        if x == 2 {
            if let d = PC.SQRT2[typename] {
                if let v = d[px] {
                    return v as! Self
                }
            } else {
                PC.SQRT2[typename] = [Int:Any]()
            }
        }
        var r0 = x < 1 ? 1 : x
        var r = r0
        let iter = max(px.msbAt + 1, 1)
        // return r.truncate(px)
        // print("\(__FILE__):\(__LINE__): px=\(px), iter=\(iter)")
        for _ in 0...iter {
            r = (x/r0 + r0) / 2
            if r == r0 { break }
            r.truncate(px + 32)
            r0 = r
        }
        if x == 2 {
            PC.SQRT2[typename]![px] = r
            return PC.SQRT2[typename]![px] as! Self
        }
        return r.truncate(px)
    }
    public static func hypot(x:Self, _ y:Self, precision:Int=64)->Self {
        #if false
        return Self(Darwin.hypot(x.toDouble(), y.toDouble()))
        #else
        return Self.sqrt(x * x + y * y, precision:precision)
        #endif
    }
    public static func exp(x:Self, precision:Int = 64)->Self {
        if let dx = x as? Double { return Self(Double.exp(dx)) }
        if x.isZero { return 1 }
        let px = Swift.max(x.precision, precision)
        let ax = x < 0 ? -x : x
        let ix = ax.toIntMax().asInt!
        let fx = ax - Self(ix)
        let epsilon = Double.ldexp(1.0, -px)
        // print("\(Self.self).exp(\(x), precision:\(precision)):ax=\(ax), ix=\(ix), fx=\(fx)")
        let inner_exp:Self->Self = { x in
            var (r, t) = (Self(1), Self(1))
            for i in 1...px {
                t *= x / Self(i)
                t.truncate(px + 32)
                r += t
                r.truncate(px + 32)
                if t.toDouble() < epsilon { break }
                // print("\(Self.self).inner_exp(\(x)):i=\(i), x=\(x.toDouble()),r=\(r.toDouble())")
            }
            return r
        }
        let e:Self = {
            let typename = "\(Self.infinity.dynamicType)"
            typealias PC = POUtil.Constants
            if let d = PC.E[typename] {
                if let v = d[px] {
                    return v as! Self
                }
            } else {
                PC.E[typename] = [Int:Any]()
            }
            PC.E[typename]![px] = inner_exp(1)
            return PC.E[typename]![px] as! Self
        }()
        //let ir = ix == 0 ? Self(1) : Int.power(inner_exp(1), ix, op:*)
        let ir = ix == 0 ? Self(1) : Int.power(e, ix, op:*)
        let fr = fx == 0 ? Self(1) : inner_exp(fx)
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
        let inner_log:Self->Self = { x in
            var t = (x - 1)/(x + 1)
            if x < 1 { t = -t }
            let t2 = t * t
            var r:Self = t
            let epsilon = Double.ldexp(1.0, -px)
            for i in 1...px*2 {
                t *= t2
                t.truncate(px + 32)
                r += t / Self(2*i + 1)
                // print("POReal#log: i=\(i), px=\(px), t=\(t.toDouble()), r=\(r.toDouble())")
                r.truncate(px + 32)
                if t.toDouble() < epsilon { break }
            }
            return 2 * (x < 1 ? -r : r)
        }
        let ln2:Self = {
            let typename = "\(Self.infinity.dynamicType)"
            typealias PC = POUtil.Constants
            if let d = PC.LN2[typename] {
                // print("\(__FILE__):\(__LINE__):LN2[\"\(typename)\"] existent")
                if let v = d[px] {
                    // print("\(__FILE__):\(__LINE__):returning LN2[\"\(typename)\"][px]")
                    return v as! Self
                }
            } else {
                // print("\(__FILE__):\(__LINE__): creating LN2[\"\(typename)\"]")
                PC.LN2[typename] = [Int:Any]()
            }
            // print("\(__FILE__):\(__LINE__): setting LN2[\(typename)][\(px)]")
            PC.LN2[typename]![px] = 2 * inner_log(sqrt(2, precision:px+32))
            return PC.LN2[typename]![px] as! Self
        }()
        let il = x.toIntMax().msbAt
        let fl = x / Self(Double.ldexp(1.0, il))
        let ir = il == 0 ? 0 : ln2 * Self(il)
        let fr = fl == 0 ? 0 : inner_log(fl)
        var r =  ir + fr
        // print("ln(\(x.toDouble())) =~ ln(\(Double.ldexp(1.0,il)))+ln(\(fl.toDouble())) = \(ir.toDouble())+\(fr.toDouble())")
        return r.truncate(px)
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
    public class Constants {
        public static var LN2   = [String:[Int:Any]]()
        public static var E     = [String:[Int:Any]]()
        public static var SQRT2 = [String:[Int:Any]]()
    }
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
    public static func sqrt(x:Double)->Double { return Glibc.sqrt(x) }
    public static func hypot(x:Double, _ y:Double)->Double { return Glibc.hypot(x, y) }
    public static func exp(x:Double)->Double   { return Glibc.exp(x) }
    public static func log(x:Double)->Double   { return Glibc.log(x) }
    #else
    public static func frexp(d:Double)->(Double, Int)   { return Darwin.frexp(d) }
    public static func ldexp(m:Double, _ e:Int)->Double { return Darwin.ldexp(m, e) }
    //
    public static func sqrt(x:Double)->Double { return Darwin.sqrt(x) }
    public static func hypot(x:Double, _ y:Double)->Double { return Darwin.hypot(x, y) }
    public static func exp(x:Double)->Double   { return Darwin.exp(x) }
    public static func log(x:Double)->Double   { return Darwin.log(x) }
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

