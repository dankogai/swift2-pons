//
//  pofloat.swift
//  pons
//
//  Created by Dan Kogai on 2/4/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

public typealias POSwiftReal = FloatingPointType

public protocol POReal : POSignedNumber {
    typealias IntType:POInt
    init(_:Double)
    func toDouble()->Double
    func %(_:Self, _:Self)->Self
    var asIntType:IntType? { get }
    var isInfinite:Bool  { get }
    var isNaN:Bool       { get }
    var isSignMinus:Bool { get }
    var isZero:Bool      { get }
    static var NaN:Self      { get }
    static var infinity:Self { get }
    var precision:Int { get }
    mutating func truncate(_:Int)->Self
    func divide(_:Self, precision:Int)->Self
    func toMixed()->(IntType, Self)
    //
    init (_:BigRat)
    init (_:BigFloat)
}
public extension POReal {
    public var isFinite:Bool { return !isInfinite }
}
public protocol POFloat : POReal {
    // static var EPSILON:Self { get }
}
// public protocol POElementaryFunctional : POReal {}
public extension POReal {
    ///
    public var abs:Self {
        return self.isSignMinus ? -self : +self
    }
    ///
    public static func abs(r:Self)->Self {
        return r.abs
    }
    public var asBigRat:BigRat? {
        if let q = self as? BigRat { return q }
        if let b = self as? BigFloat { return b.asBigRat }
        if let d = self as? Double { return BigRat(d) }
        return BigRat(self.toDouble())
    }
    ///
    public static func getSetConstant(
        name:String, _ arg:Self, _ precision:Int, setter:(Self, Int)->Self
        )->Self
    {
        #if false   // to test constant cache
            return setter(arg, precision)
        #else
            let key = "\(Self.self).\(name)(\(arg), precision:\(precision))"
            // print("\(__FILE__):\(__LINE__) fetching \(key)")
            if let value = POUtil.constants[key] {
                return value as! Self
            }
            let value = setter(arg, precision)
            // print("\(__FILE__):(__LINE__) storing \(key) => \(value)")
            POUtil.constants[key] = value
            return value
        #endif
    }
    /// To floating-point string
    public func toFPString(base:Int=10, places:Int=0)->String {
        guard 2 <= base && base <= 36 else {
            fatalError("base out of range. \(base) is not within 2...36")
        }
        if self.isNaN || self.isZero || self.isInfinite {
            return self.toDouble().description
        }
        let dfactor = Double.log(2) / Double.log(Double(base))
        var ndigits = places != 0 ? places
            : Int( Double(self.precision) * dfactor ) + 2
        let (int, fract) = self.toMixed()
        if fract.isZero { return int.toString(base) + ".0" }
        var afract = fract < 0 ? -fract : fract
        if 64 < self.precision {    // get all digits at once
            var bfract = afract.asBigRat!
            let zcount = Int(Double(bfract.den.msbAt - bfract.num.msbAt) * dfactor)
            let zfill = (0..<zcount).map{_ in "0"}.joinWithSeparator("")
            bfract *= BigInt.pow(BigInt(base), BigInt(ndigits)).over(1)
            let (b, residue) = bfract.toMixed()
            var d:BigInt = 0
            if residue < BigInt(1).over(2) {    // no roundup required
                d = b
            } else {
                let c = b + 1
                if b.msbAt == c.msbAt {
                    d = c
                } else {
                    return ((self.isSignMinus ? -1 : 1) + int).toString(base) + ".0"
                }
            }            
            return int.toString(base) + "." + zfill + d.toString(base)
        } else {   // classical digit-by-digit method
            var digits = [Int]()
            var started = false
            while 0 < ndigits {
                var r:IntType
                afract *= Self(base)
                (r, afract) = afract.toMixed()
                if r != 0 { started = true }
                digits.append(r.asInt!)
                if afract == 0 { break }
                if started { ndigits -= 1 }
            }
            // print("v=\(v.toDouble()), digits = \(digits.map{POUtil.int2char[$0]})")
            if afract * 2 >= 1 {   // round up!
                var idx = digits.count
                // print("BEFORE:digits = \(digits.map{POUtil.int2char[$0]})")
                while 0 < idx {
                    if digits[idx - 1] < base - 1 {
                        digits[idx - 1] += 1
                        break
                    }
                    digits[idx - 1] = 0
                    idx -= 1
                }
                // print("AFTER:digits = \(digits.map{POUtil.int2char[$0]})")
                if idx == 0 { // carried away :-)
                    return ((self.isSignMinus ? -1 : 1) + int).toString(base) + ".0"
                }
            }
            return int.toString(base) + "." +  digits.map{"\(POUtil.int2char[$0])"}.joinWithSeparator("")
        }
    }
    ////
    public static func pow(x:Self, _ y:Self, precision:Int = 64)->Self  {
        return Self(Double.pow(x.toDouble(), y.toDouble()))
    }
    // public static func sqrt(x:Self)->Self   { return Self(Darwin.sqrt(x.toDouble())) }
    /// - returns: square root of `x` to precision `precision`
    public static func sqrt(x:Self, precision:Int = 64)->Self {
        if let dx = x as? Double { return Self(Double.sqrt(dx)) }
        if x.isNaN || x.isSignMinus || x.isZero || x.isInfinite {
            return Self(Double.sqrt(x.toDouble()))
        }
        let px = Swift.max(x.precision, precision)
        let q = x.asBigRat!
        let n = q.numerator   << BigInt(px * 2)
        let d = q.denominator << BigInt(px * 2)
        return Self(BigInt.isqrt(n).over(BigInt.isqrt(d)))
    }
    /// - returns: `sqrt(x*x + y*y)` witout overflow
    public static func hypot(x:Self, _ y:Self, precision:Int=64)->Self {
        if let dx = x as? Double { return Self(Double.hypot(dx, y as! Double)) }
        // return Self.sqrt(x * x + y * y, precision:precision)
        let px = Swift.max(x.precision, precision)
        var (r, l) = (x < 0 ? -x : x, y < 0 ? -y : y)
        if r < l { (r, l) = (l, r) }
        if l == 0 { return r }
        let epsilon = Self(Double.ldexp(1.0, -px))
        while epsilon < l {
            var t = l / r
            t *= t
            t /= 4 + t
            r += 2 * r * t
            l *= t
            r.truncate(px * 2)
            l.truncate(px * 2)
            // print("r=\(r.toDouble()), l=\(l.toDouble()), epsilon=\(epsilon.toDouble())")
        }
        return r.truncate(px)
    }
    ///
    public static func exp(x:Self, precision:Int = 64)->Self {
        if let dx = x as? Double { return Self(Double.exp(dx)) }
        if x.isZero { return 1 }
        let px = Swift.max(x.precision, precision)
        let (ix, fx) = x.abs.toMixed() //toIntMax().asInt!
        let inner_exp:(Self, Int)->Self = { x, px in
            var (r, n, d) = (Self(1), Self(1), Self(1))
            for i in 1...px {
                n *= x
                d *= Self(i)
                r += n / d
                if px < d.precision { break }
            }
            return r
        }
        let e = getSetConstant("exp", Self(1), px, setter:inner_exp)
        let ir = ix == 0 ? Self(1) : IntType.power(e, ix, op:*)
        let fr = fx == 0 ? Self(1) : inner_exp(fx, px)
        var r = ir * fr
        return x.isSignMinus ? 1/r.truncate(px) : r.truncate(px)
    }
    /// ![](https://upload.wikimedia.org/math/1/7/5/17534a763ff4b0fd87ce62556ebcc3d7.png)
    ///
    /// - returns: natural log of `x`
    ///
    public static func log(x:Self, precision:Int = 64)->Self {
        if let dx = x as? Double { return Self(Double.log(dx)) }
        if x.isSignMinus || x.isZero || x == 1 {
            return Self(Double.log(x.toDouble()))
        }
        let px = Swift.max(x.precision, precision)
        let epsilon = Self(Double.ldexp(1.0, -px))
        #if true    // euler
        let inner_log:(Self, Int)->Self = { x , px in
            var t = (x - 1).divide(x + 1, precision:px)
            if x < 1 { t = -t }
            let t2 = t * t
            var r:Self = t
            for i in 1...px*2 {
                t *= t2
                t.truncate(px + 32)
                r += t / Self(2*i + 1)
                // print("POReal#log: i=\(i), px=\(px), t=\(t.toDouble()), r=\(r.toDouble())")
                r.truncate(px + 32)
                if t < epsilon { break }
            }
            return 2 * (x < 1 ? -r : r)
        }
        #else   // newton-raphson
        let inner_log:(Self, Int)->Self = { x, px in
            var y = Self(1)
            for _ in 0...(x.precision.msbAt + 1) {
                let ex = exp(y, precision:px + 32)
                var t = Self(2) * (x - ex)/(x + ex)
                y += t.truncate(px + 32)
                // print("log: i=\(i), y=\(y.toFPString()), t=\(t.toDouble())")
                if (t < 0 ? -t : t) < epsilon { break }
            }
            return y
        }
        #endif
        let ln2 = getSetConstant("log", 2, px, setter:inner_log)
        //let ln2 = 2 * lnr2 //getSetConstant("log", 2, px, setter:inner_log)
        let il = x.toMixed().0.msbAt
        let fl = x.divide(Self(Double.ldexp(1.0, il)), precision:px)
        let ir = il == 0 ? 0 : ln2 * Self(il)
        let fr = fl == 1 ? 0 : inner_log(fl, px)
        var r =  ir + fr
        //print("ln(\(x.toDouble())) =~ ln(\(Double.ldexp(1.0,il)))+ln(\(fl.toDouble()))"
        //    + " = \(ir.toDouble())+\(fr.toDouble()) = \(r.toDouble())")
        return r.truncate(px)
    }
    ///
    public static func sincos(x:Self, precision:Int = 64)->(sin:Self, cos:Self) {
        if let dx = x as? Double { return (Self(Double.sin(dx)), Self(Double.cos(dx)))}
        if x.isZero {
            return (Self(Double.sin(x.toDouble())), +1)
        }
        let px = Swift.max(x.precision, precision)
        let atan1   = pi_4(px)
        let sqrt1_2 = sqrt2(px)/2
        func inner_cossin(x:Self)->(Self, Self) {
            if 1 < x.abs {  // use double-angle formula to reduce x
                let (c, s) = inner_cossin(x/2)
                if c == s { return (0, 1) } // prevent error accumulation
                return (c*c - s*s, 2 * s * c)
            }
            if x.abs == atan1 {
                return (x.isSignMinus ? -sqrt1_2 : +sqrt1_2, +sqrt1_2)
            }
            var (c, s) = (Self(0), Self(0))
            var (n, d) = (Self(1), Self(1))
            for i in 0...px {
                var t = n.divide(d, precision:px + 16)
                t.truncate(px + 16)
                if i & 1 == 0 {
                    c += i & 2 == 2 ? -t : +t
                } else {
                    s += i & 2 == 2 ? -t : +t
                }
                // print("inner_cossin:i=\(i), px=\(px), d.precision=:\(d.precision)")
                if px < d.precision { break }
                n *= x
                d *= Self(i+1)
            }
            return (c, s)
        }
        var (c, s) = inner_cossin(x)
        return (s.truncate(px), c.truncate(px))
    }
    ///
    public static func cos(x:Self, precision:Int = 64)->Self {
        // return Self(Double.cos(x.toDouble()))
        if let dx = x as? Double { return Self(Double.cos(dx)) }
        let px = Swift.max(x.precision, precision)
        return sincos(x, precision:px).cos
    }
    ///
    public static func sin(x:Self, precision:Int = 64)->Self {
        // return Self(Double.sin(x.toDouble()))
        if let dx = x as? Double { return Self(Double.sin(dx)) }
        let px = Swift.max(x.precision, precision)
        return sincos(x, precision:px).sin
    }
    ///
    public static func tan(x:Self, precision px:Int = 64)->Self {
        // return Self(Double.tan(x.toDouble()))
        if let dx = x as? Double { return Self(Double.tan(dx)) }
        if x.isZero {
            return Self(Double.tan(x.toDouble()))
        }
        let (s, c) = sincos(x, precision:px)
        return (s / c)
        // return sin(x, precision:px) / cos(x, precision:px)
    }
    ///
    public static func acos(x:Self, precision px:Int = 64)->Self   {
        if let dx = x as? Double { return Self(Double.acos(dx)) }
        if x == 1 || 1 < x.abs {
            return Self(Double.acos(x.toDouble()))
        }
        return pi(px)/2 - asin(x, precision:px)
    }
    ///
    public static func asin(x:Self, precision px:Int = 64)->Self   {
        if let dx = x as? Double { return Self(Double.asin(dx)) }
        if x.isZero || 1 < x.abs {
            return Self(Double.asin(x.toDouble()))
        }
        let a = x / (1 + sqrt(1 - x * x, precision:px))
        return 2 * atan(a, precision:px)
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
                t *= 2 * (Self(i) * x2).divide(Self(2 * i + 1) * x2p1, precision:px)
                t.truncate(px + 32)
                r += t
                r.truncate(px + 32)
                if t < epsilon { break }
            }
            return r * x / x2p1
        }
        let atan1 = pi_4(px)    // getSetConstant("atan", 1, px, setter:{_, px in pi(px)/4 })
        let ax = x < 0 ? -x : x
        if ax == 1 { return x < 0 ? -atan1 : atan1 }
        var final = ax < 1 ? inner_atan(ax, px) : 2 * atan1 - inner_atan(1/ax, px)
        return x < 0 ? -final.truncate(px) : final.truncate(px)
    }
    public static func atan2(y:Self, _ x:Self, precision:Int = 64)->Self {
        if let dy = y as? Double { return Self(Double.atan2(dy, x as! Double)) }
        let px = Swift.max(x.precision, precision)
        if x.isNaN || y.isNaN { return Self.NaN }
        // let us follow Double.atan2 for these special cases
        if x.isZero || y.isZero || x.isInfinite || y.isInfinite {
            return Self(Double.atan2(y.toDouble(), x.toDouble()))
        }
        if x < 0 {
            return atan(y/x, precision:px) + (y < 0 ? -pi(px) : +pi(px))
        } else {
            return atan(y/x, precision:px)
        }
    }
    ///
    public static func cosh(x:Self, precision px:Int = 64)->Self   {
        if let dx = x as? Double { return Self(Double.cosh(dx)) }
        return (exp(+x, precision:px) + exp(-x, precision:px)) / 2
    }
    ///
    public static func sinh(x:Self, precision px:Int = 64)->Self   {
        if let dx = x as? Double { return Self(Double.sinh(dx)) }
        if x.isZero || x.isInfinite {
            return Self(Double.sinh(x.toDouble()))
        }
        return (exp(+x, precision:px) - exp(-x, precision:px)) / 2
    }
    ///
    public static func tanh(x:Self, precision px:Int = 64)->Self   {
        if let dx = x as? Double { return Self(Double.tanh(dx)) }
        if x.isZero || x.isInfinite {
            return Self(Double.tanh(x.toDouble()))
        }
        let epx = exp(+x, precision:px)
        let enx = exp(-x, precision:px)
        return (epx - enx).divide(enx + epx, precision:px)
    }
    ///
    public static func acosh(x:Self, precision px:Int = 64)->Self   {
        if let dx = x as? Double { return Self(Double.acosh(dx)) }
        if x <= 1 || x.isInfinite {
            return Self(Double.acosh(x.toDouble()))
        }
        let a = x + sqrt(x * x - 1, precision:px)
        return log(a, precision:px)
    }
    ///
    public static func asinh(x:Self, precision px:Int = 64)->Self   {
        if let dx = x as? Double { return Self(Double.asinh(dx)) }
        if x.isZero || x.isInfinite {
            return Self(Double.asinh(x.toDouble()))
        }
        // let a = x + sqrt(x * x + 1, precision:px)
        let a = x + hypot(x, 1, precision:px)
        return log(a, precision:px)
    }
    ///
    public static func atanh(x:Self, precision px:Int = 64)->Self   {
        if let dx = x as? Double { return Self(Double.atanh(dx)) }
        if x.isZero || 1 <= x.abs {
            return Self(Double.atanh(x.toDouble()))
        }
        let a = (1 + x).divide(1 - x, precision:px)
        return log(a, precision:px) / 2
    }
    ///
    /// π in precision `precision`
    ///
    /// By default it uses [Bellar's Formula].
    ///
    /// [Bellar's Formula]: https://en.wikipedia.org/wiki/Bellard%27s_formula
    ///
    /// ![](https://upload.wikimedia.org/math/d/b/f/dbf2d4355c108f6b3388985be4976799.png)
    ///
    public static func pi_4(px:Int = 64, verbose:Bool=false)->Self {
        if Self.self == Double.self { return Self(Double.PI/4) }
        return getSetConstant("atan", 1, px) { _, px in
            let epsilon = Self(Double.ldexp(1.0, -px))
            //if verbose && Self.self != BigFloat.self && 65536 < px {
            #if false
                // Gauss–Legendre algorithm -- very expensive for BigRat
                var (a0, b0, t0, p0) = (Self(1), sqrt(Self(0.5), precision:px + 32), Self(0.25), Self(1))
                var (a, b, t, p) = (a0, b0, t0, p0)
                for i in 0..<(px.msbAt) {
                    a = (a0 + b0) / 2
                    b = sqrt(a0 * b0, precision:px + 32)
                    let a0_a = (a0 - a)
                    t = t0 - p0 * a0_a*a0_a
                    p = 2 * p
                    if verbose {
                        print("iter[\(i)]: p = \(p), a.precision = \(a.precision)")
                    }
                    a.truncate(px + 32)
                    b.truncate(px + 32)
                    t.truncate(px + 32)
                    p.truncate(px + 32)
                    (a0, b0, t0, p0) = (a, b, t, p)
                }
                let a_b = (a + b)
                var pi_4 = (a_b*a_b).divide(16 * t, precision:px)
                return pi_4.truncate(px)
            //} else {
            #else
                // Default: Bellard's Formula
                var p64 = Self(0)
                for i in 0..<px {
                    var t = Self(0)
                    t -= Self(1<<5).divide(Self( 4 * i + 1), precision:px)
                    t -= Self(1<<0).divide(Self( 4 * i + 3), precision:px)
                    t += Self(1<<8).divide(Self(10 * i + 1), precision:px)
                    t -= Self(1<<6).divide(Self(10 * i + 3), precision:px)
                    t -= Self(1<<2).divide(Self(10 * i + 5), precision:px)
                    t -= Self(1<<2).divide(Self(10 * i + 7), precision:px)
                    t += Self(1<<0).divide(Self(10 * i + 9), precision:px)
                    if 0 < i {
                        t = t.divide(Int.power(Self(2), 10 * i, op:*), precision:px)
                    }
                    p64 += i & 1 == 1 ? -t : t
                    // p64.truncate(px + 32)
                    if verbose {
                        print("\(Self.self).pi(\(px)):i=\(i), t.precision=\(t.precision)")
                    }
                    // t.truncate(px + 32)
                    if t < epsilon { break }
                }
                p64 /= Self(1<<8)
                return p64.truncate(px)
            //}
            #endif
        }
    }
    public static func pi(px:Int = 64, verbose:Bool=false)->Self {
        if Self.self == Double.self { return Self(Double.PI) }
        return 4 * pi_4(px)
    }
    public static func e(px:Int = 64, verbose:Bool=false)->Self {
        if Self.self == Double.self { return Self(Double.E) }
        return getSetConstant("exp", 1, px, setter:exp)
    }
    public static func ln2(px:Int = 64, verbose:Bool=false)->Self {
        if Self.self == Double.self { return Self(Double.LN2) }
        return getSetConstant("log", 2, px, setter:log)
    }
    public static func ln10(px:Int = 64, verbose:Bool=false)->Self {
        if Self.self == Double.self { return Self(Double.LN10) }
        return getSetConstant("log", 10, px, setter:log)
    }
    public static func sqrt2(px:Int = 64, verbose:Bool=false)->Self {
        if Self.self == Double.self { return Self(Double.SQRT2) }
        return getSetConstant("sqrt", 2, px, setter:sqrt)
    }
    public static var LOG2E:Self    { return Self(M_LOG2E) }
    public static var LOG10E:Self   { return Self(M_LOG10E) }

}
public extension POUtil {
    public static var constants = [String:Any]()
}
public extension POFloat {
    public func toString(base:Int = 10)->String {
        return self.toFPString(base)
    }
    public var description:String {
        return self.toString()
    }
    public var debugDescription:String {
        return self.toString(16)
    }
}
extension Double : POFloat {
    public typealias IntType = Int
    public func toDouble()->Double { return self }
    public func toIntMax()->IntMax { return IntMax(self) }
    public var asIntType:IntType? { return IntType(self) }
    public func toMixed()->(IntType, Double) {
        return (IntType(self), self % 1.0)
    }
    /// number of significant bits == 53
    public static let precision = 53
    public var precision:Int { return Double.precision }
    public func truncate(bits:Int)->Double { return self }
    public func divide(by:Double, precision:Int=53)->Double { return self / by }
}
extension Float : POFloat {
    public typealias IntType = Int
    public func toDouble()->Double { return Double(self) }
    public func toIntMax()->IntMax { return IntMax(self) }
    public var asIntType:IntType? { return IntType(self) }
    public func toMixed()->(IntType, Float) {
        return (IntType(self), self % 1.0)
    }
    /// number of significant bits == 23
    public static let precision = 24
    public var precision:Int { return Float.precision }
    public func truncate(bits:Int)->Float { return self }
    public func divide(by:Float, precision:Int=24)->Float { return self / by }
}
//
// platform compatibility layer at the end
//
#if os(Linux)
    import Glibc
#else
    import Darwin
#endif
public extension Double {
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
    public static func pow(x:Double, _ y:Double, precision:Int=53)->Double  { return Glibc.pow(x, y) }
    public static func sqrt(x:Double, precision:Int=53)->Double     { return Glibc.sqrt(x) }
    public static func hypot(x:Double, _ y:Double, precision:Int=53)->Double { return Glibc.hypot(x, y) }
    public static func exp(x:Double, precision:Int=53)->Double      { return Glibc.exp(x) }
    public static func log(x:Double, precision:Int=53)->Double      { return Glibc.log(x) }
    public static func log10(x:Double, precision:Int=53)->Double    { return Glibc.log10(x) }
    public static func cos(x:Double, precision:Int=53)->Double      { return Glibc.cos(x) }
    public static func sin(x:Double, precision:Int=53)->Double      { return Glibc.sin(x) }
    public static func tan(x:Double, precision:Int=53)->Double      { return Glibc.tan(x) }
    public static func acos(x:Double, precision:Int=53)->Double     { return Glibc.acos(x) }
    public static func asin(x:Double, precision:Int=53)->Double     { return Glibc.asin(x) }
    public static func atan(x:Double, precision:Int=53)->Double     { return Glibc.atan(x) }
    public static func atan2(y:Double, _ x:Double, precision:Int=53)->Double { return Glibc.atan2(y, x) }
    public static func cosh(x:Double, precision:Int=53)->Double     { return Glibc.cosh(x) }
    public static func sinh(x:Double, precision:Int=53)->Double     { return Glibc.sinh(x) }
    public static func tanh(x:Double, precision:Int=53)->Double     { return Glibc.tanh(x) }
    public static func acosh(x:Double, precision:Int=53)->Double    { return Glibc.acosh(x) }
    public static func asinh(x:Double, precision:Int=53)->Double    { return Glibc.asinh(x) }
    public static func atanh(x:Double, precision:Int=53)->Double    { return Glibc.atanh(x) }
    #else
    public static func frexp(d:Double)->(Double, Int)   { return Darwin.frexp(d) }
    public static func ldexp(m:Double, _ e:Int)->Double { return Darwin.ldexp(m, e) }
    //
    public static func pow(x:Double, _ y:Double, precision:Int=53)->Double  { return Darwin.pow(x, y) }
    public static func sqrt(x:Double, precision:Int=53)->Double     { return Darwin.sqrt(x) }
    public static func hypot(x:Double, _ y:Double, precision:Int=53)->Double { return Darwin.hypot(x, y) }
    public static func exp(x:Double, precision:Int=53)->Double      { return Darwin.exp(x) }
    public static func log(x:Double, precision:Int=53)->Double      { return Darwin.log(x) }
    public static func log10(x:Double, precision:Int=53)->Double     { return Darwin.log10(x) }
    public static func cos(x:Double, precision:Int=53)->Double      { return Darwin.cos(x) }
    public static func sin(x:Double, precision:Int=53)->Double      { return Darwin.sin(x) }
    public static func tan(x:Double, precision:Int=53)->Double      { return Darwin.tan(x) }
    public static func acos(x:Double, precision:Int=53)->Double     { return Darwin.acos(x) }
    public static func asin(x:Double, precision:Int=53)->Double     { return Darwin.asin(x) }
    public static func atan(x:Double, precision:Int=53)->Double     { return Darwin.atan(x) }
    public static func atan2(y:Double, _ x:Double, precision:Int=53)->Double { return Darwin.atan2(y, x) }
    public static func cosh(x:Double, precision:Int=53)->Double     { return Darwin.cosh(x) }
    public static func sinh(x:Double, precision:Int=53)->Double     { return Darwin.sinh(x) }
    public static func tanh(x:Double, precision:Int=53)->Double     { return Darwin.tanh(x) }
    public static func acosh(x:Double, precision:Int=53)->Double    { return Darwin.acosh(x) }
    public static func asinh(x:Double, precision:Int=53)->Double    { return Darwin.asinh(x) }
    public static func atanh(x:Double, precision:Int=53)->Double    { return Darwin.atanh(x) }
    #endif
    public static var PI      = M_PI
    public static var E       = M_E
    public static var LN2     = M_LN2
    public static var LN10    = M_LN10
    public static var LOG2E   = M_LOG2E
    public static var LOG10E  = M_LOG10E
    public static var SQRT1_2 = M_SQRT1_2
    public static var SQRT2   = M_SQRT2
}
