//
//  pocomplex.swift
//  pons
//
//  Created by Dan Kogai on 2/6/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

///
/// Complex of any POSignedNumber
///
public protocol POComplex: PONumber {
    typealias RealType:POSignedNumber
    var re:RealType { get set }
    var im:RealType { get set }
    init(_:RealType, _:RealType)
}
public func ==<C:POComplex>(lhs:C, rhs:C)->Bool {
    return lhs.re == rhs.re && lhs.im == rhs.im
}
public func ==<C:POComplex>(lhs:C, rhs:C.RealType)->Bool {
    return lhs.im == 0 && lhs.re == rhs
}
public func ==<C:POComplex>(lhs:C.RealType, rhs:C)->Bool {
    return rhs.im == 0 && rhs.re == lhs
}
extension POComplex {
    /// self * (0.0+1.0.i)
    public var i:Self { return Self(-im, re) }
    /// conjugate of `self`
    public var conj:Self { return Self(re, -im) }
    /// conjugate of `z`
    public static func conj(z:Self) -> Self { return z.conj }
    /// norm of self == abs(self)**2
    public var norm:RealType { return re*re + im*im }
    /// norm of z
    public static func norm(z:Self) -> RealType { return z.norm }
    /// real part of `self`
    public var real:RealType { return re }
    /// real part of `z`
    public static func real(z:Self) -> RealType { return z.re }
    /// imag part of `self`
    public var imag:RealType { return im }
    /// imag part of `z`
    public static func imag(z:Self) -> RealType { return z.im }
    /// converts to real number or `nil` if it fails
    public var asReal:RealType? { return im == 0 ? re : nil }
    /// stringifies `self`
    public var description:String {
        let sign = im.isSignMinus ? "" : "+"
        return "(\(re)\(sign)\(im).i)"
    }
    /// hash value of `self`
    public var hashValue:Int {
        let bits = sizeof(Int) * 4
        return ((re.hashValue >> bits) << bits) | (im.hashValue >> bits)
    }
    /// converts `self` to `IntMax`
    public func toIntMax()->IntMax {
        guard im != 0 else {
            fatalError("im == \(im) != 0")
        }
        return re.toIntMax()
    }
    public static var zero:Self { return Self(0, 0) }
    public static var one:Self  { return Self(1, 0) }
}
// prefix +
public prefix func +<C:POComplex>(z:C) -> C {
    return z
}
// prefix -
public prefix func -<C:POComplex>(z:C) -> C {
    return C(-z.re, -z.im)
}
// infix +
public func +<C:POComplex>(lhs:C, rhs:C) -> C {
    return C(lhs.re + rhs.re, lhs.im + rhs.im)
}
public func +<C:POComplex>(lhs:C, rhs:C.RealType) -> C {
    return lhs + C(rhs, 0)
}
public func +<C:POComplex>(lhs:C.RealType, rhs:C) -> C {
    return C(lhs, 0) + rhs
}
// infix -
public func -<C:POComplex>(lhs:C, rhs:C) -> C {
    return C(lhs.re - rhs.re, lhs.im - rhs.im)
}
public func -<C:POComplex>(lhs:C, rhs:C.RealType) -> C {
    return lhs - C(rhs, 0)
}
public func -<C:POComplex>(lhs:C.RealType, rhs:C) -> C {
    return C(lhs, 0) - rhs
}
// infix *
public func *<C:POComplex>(lhs:C, rhs:C) -> C {
    return C(
        lhs.re * rhs.re - lhs.im * rhs.im,
        lhs.re * rhs.im + lhs.im * rhs.re
    )
}
public func *<C:POComplex>(lhs:C, rhs:C.RealType) -> C {
    return C(lhs.re * rhs, lhs.im * rhs)
}
public func *<C:POComplex>(lhs:C.RealType, rhs:C) -> C {
    return C(lhs * rhs.re, lhs * rhs.im)
}
// infix /
public func /<C:POComplex>(lhs:C, rhs:C) -> C {
    return (lhs * rhs.conj) / rhs.norm
}
public func /<C:POComplex>(lhs:C, rhs:C.RealType) -> C {
    return C(lhs.re / rhs, lhs.im / rhs)
}
public func /<C:POComplex>(lhs:C.RealType, rhs:C) -> C {
    return C(lhs, 0) / rhs
}
// infix % -- mainly for gaussian int
public func %<C:POComplex>(lhs:C, rhs:C) -> C {
    return lhs - (lhs / rhs) * rhs
}
///
/// Complex Integer
///
public struct GaussianInt<R:POInt> : POComplex {
    public typealias RealType = R
    public var (re, im):(R, R)
    public init(_ r:R, _ i:R) { (re, im) = (r, i) }
    public init(_ r:R) { self.init(r, 0) }
    public init() { self.init(0, 0) }
    public init(_ z:GaussianInt) { (re, im) = (z.re, z.im) }
    public init(_ i:Int) { self.init(RealType(i), 0) }
}
public extension POInt {
    public var i:GaussianInt<Self>{ return GaussianInt(0, self) }
}
///
/// Complex Real
///
public protocol POComplexReal : POComplex {
    typealias RealType: POReal
}
public extension POComplexReal {
    public init(abs:RealType, arg:RealType) {
        self.init(abs * RealType.cos(arg), abs * RealType.sin(arg))
    }
    /// absolute value of `self`
    public var abs:RealType {
        get { return RealType.hypot(re, im) }
        set {
            let r = newValue / abs
            (re, im) = (re * r, im * r)
        }
    }
    public static func abs(z:Self)->RealType { return z.abs }
    /// argument of `self`
    public var arg:RealType  {
        get { return RealType.atan2(im, re) }
        set {
            let m = abs
            (re, im) = (m * RealType.cos(newValue), m * RealType.sin(newValue))
        }
    }
    public static func arg(z:Self)->RealType { return z.arg }
    /// projection of `self`
    public var proj:Self {
        if re.isFinite && im.isFinite {
            return self
        } else {
            return Self(
                RealType(1)/RealType(0),
                im.isSignMinus ? -RealType(0) : +RealType(0)
            )
        }
    }
    public static func proj(z:Self)->Self { return z.proj }
}
public func abs<C:POComplexReal>(z:C)->C.RealType { return z.abs }
public func arg<C:POComplexReal>(z:C)->C.RealType { return z.arg }
public func proj<C:POComplexReal>(z:C)->C { return z.proj }
///
/// Complex Real
///
public struct Complex<R:POReal> : POComplexReal {
    public typealias RealType = R
    public var (re, im):(R, R)
    public init(_ r:R, _ i:R) { (re, im) = (r, i) }
    public init(_ r:R) { self.init(r, 0) }
    public init() { self.init(0, 0) }
    public init(_ z:Complex) { (re, im) = (z.re, z.im) }
    public init(_ i:Int) { self.init(RealType(i), 0) }
}
public extension POReal {
    public var i:Complex<Self>{ return Complex(0, self) }
}
/*
 * with basic stuff done, let's add elementary functions!
 */
public extension POComplexReal {
    private typealias R = RealType  // for ease of coding
    /// - returns: square root of z in Complex
    public static func sqrt(z:Self, precision p:Int=64) -> Self {
        // return z ** 0.5
        let d = R.hypot(z.re, z.im, precision:p)
        let r = R.sqrt((z.re + d)/R(2), precision:p)
        if z.im < 0 {
            return Self(r, -R.sqrt((-z.re + d)/2, precision:p))
        } else {
            return Self(r, +R.sqrt((-z.re + d)/2, precision:p))
        }
    }
    public static func sqrt(r:R, precision p:Int=64) -> Self { return sqrt(Self(r, 0), precision:p) }
    /// - returns: e ** z in Complex
    public static func exp(z:Self, precision p:Int=64) -> Self {
        let r = R.exp(z.re, precision:p)
        let a = z.im
        let (s, c) = R.sincos(a, precision:p)
        return Self(r * c, r * s)
    }
    public static func exp(r:R, precision p:Int=64) -> Self { return exp(Self(r, 0), precision:p) }
    /// - returns: natural log of z in Complex
    public static func log(z:Self, precision p:Int=64) -> Self {
        return Self(R.log(z.abs, precision:p), z.arg)
    }
    public static func log(r:R, precision p:Int=64) -> Self { return log(Self(r, 0), precision:p) }
    /// - returns: log 10 of z in Complex
    public static func log10(z:Self, precision p:Int=64) -> Self {
        return log(z, precision:p) / R.ln10(p)
    }
    public static func log10(r:R, precision p:Int=64) -> Self { return log10(Self(r, 0), precision:p) }
    /// - returns: lhs ** rhs in Complex
    public static func pow(lhs:Self, _ rhs:Self) -> Self {
        return exp(log(lhs) * rhs)
    }
    public static func pow(lhs:Self, _ rhs:R) -> Self {
        if lhs == zero {
            if 0 <  rhs { return zero }
            if 0 == rhs { return Self(0/0, 0) }
            // print("lhs=\(lhs), rhs=\(rhs)")
            let sig:R = lhs.re.isSignMinus && rhs.toDouble() % 2 == -1 ? -1 : 1
            return Self(sig/0, 0)
        }
        if rhs == 0 {
            return one // x ** 0 == 1 for any x; 1 ** y == 1 for any y
        }
        let ax = rhs.isSignMinus ? -rhs : rhs
        let ix = ax.toIntMax().asInt!
        let ip = ix < 1 ? one : Int.power(lhs, ix, op:*)
        let fx = ax - R(ix)
        let fp = fx < R(0.5) ? pow(lhs, Self(fx, 0)) : sqrt(lhs) * pow(lhs, Self(fx - R(0.5),0))
        let ap = ip * fp
        return rhs.isSignMinus ? Self(1, 0) / ap : ap
    }
    /// - returns: cosine of z in Complex
    public static func cos(z:Self, precision p:Int=64) -> Self {
        //return (exp(z.i) + exp(-z.i)) / 2
        return Self(
            +R.cos(z.re, precision:p) * R.cosh(z.im, precision:p),
            -R.sin(z.re, precision:p) * R.sinh(z.im, precision:p)
        )
    }
    public static func cos(r:R, precision p:Int=64) -> Self { return cos(Self(r, 0), precision:p) }
    /// - returns: sine of z in Complex
    public static func sin(z:Self, precision p:Int=64) -> Self {
        // return -(exp(z.i) - exp(-z.i)).i / 2
        return Self(
            +R.sin(z.re, precision:p) * R.cosh(z.im, precision:p),
            +R.cos(z.re, precision:p) * R.sinh(z.im, precision:p))
    }
    public static func sin(r:R, precision p:Int=64) -> Self { return sin(Self(r, 0),  precision:p) }
    /// - returns: tangent of z in Complex
    public static func tan(z:Self, precision p:Int=64) -> Self {
        return sin(z, precision:p) / cos(z, precision:p)
    }
    public static func tan(r:R,  precision p:Int=64) -> Self { return tan(Self(r, 0),  precision:p) }
    /// - returns: arc cosine of z in Complex
    public static func acos(z:Self, precision p:Int=64) -> Self {
        return log(z - sqrt(1 - z*z, precision:p).i,  precision:p).i
    }
    public static func acos(r:R, precision p:Int=64) -> Self { return acos(Self(r, 0),  precision:p) }
    /// - returns: arc sine of z in Complex
    public static func asin(z:Self,  precision p:Int=64) -> Self {
        return -log(z.i + sqrt(1 - z*z, precision:p)).i
    }
    public static func asin(r:R, precision p:Int=64) -> Self { return asin(Self(r, 0), precision:p) }
    /// - returns: arc tangent of z in Complex
    public static func atan(z:Self, precision p:Int=64) -> Self {
        let lp = log(1 - z.i, precision:p)
        let lm = log(1 + z.i, precision:p)
        return (lp - lm).i / 2
    }
    public static func atan(r:R) -> Self { return atan(Self(r, 0)) }
    /// - returns: hyperbolic cosine of z in Complex
    public static func cosh(z:Self, precision p:Int=64) -> Self {
        // return (exp(z) + exp(-z)) / T(2)
        return cos(z.i, precision:p)
    }
    public static func cosh(r:R, precision p:Int=64) -> Self { return cosh(Self(r, 0), precision:p) }
    /// - returns: hyperbolic sine of z in Complex
    public static func sinh(z:Self, precision p:Int=64) -> Self {
        // return (exp(z) - exp(-z)) / T(2)
        return -sin(z.i, precision:p).i;
    }
    public static func sinh(r:R, precision p:Int=64) -> Self { return sinh(Self(r, 0), precision:p) }
    /// - returns: hyperbolic tangent of z in Complex
    public static func tanh(z:Self, precision p:Int=64) -> Self {
        // let ez = exp(z), e_z = exp(-z)
        // return (ez - e_z) / (ez + e_z)
        return sinh(z, precision:p) / cosh(z, precision:p)
    }
    public static func tanh(r:R, precision p:Int=64) -> Self { return tanh(Self(r, 0), precision:p) }
    /// - returns: inverse hyperbolic cosine of z in Complex
    public static func acosh(z:Self, precision p:Int=64) -> Self {
        return log(z + sqrt(z*z - 1, precision:p), precision:p)
    }
    public static func acosh(r:R, precision p:Int=64) -> Self { return acosh(Self(r, 0), precision:p) }
    /// - returns: inverse hyperbolic sine of z in Complex
    public static func asinh(z:Self, precision p:Int=64) -> Self {
        return log(z + sqrt(z*z + 1, precision:p), precision:p)
    }
    public static func asinh(r:R, precision p:Int=64) -> Self { return asinh(Self(r, 0), precision:p) }
    /// - returns: inverse hyperbolic tangent of z in Complex
    public static func atanh(z:Self, precision p:Int=64) -> Self {
        return log((1 + z) / (1 - z)) / 2
    }
    public static func atanh(r:R, precision p:Int=64) -> Self { return atanh(Self(r, 0), precision:p) }
}
