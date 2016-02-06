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
extension POComplex {
    public var conj:Self { return Self(re, -im) }
    public var norm:RealType { return re*re + im*im }
    public var i:Self { return Self(-im, re) }
    public var description:String {
        let sign = im.isSignMinus ? "" : "+"
        return "(\(re)\(sign)\(im).i)"
    }
    public var hashValue:Int {
        let bits = sizeof(Int) * 4
        return ((re.hashValue >> bits) << bits) | (im.hashValue >> bits)
    }
    public func toIntMax()->IntMax {
        guard im != 0 else {
            fatalError("im == \(im) != 0")
        }
        return re.toIntMax()
    }
}
/// conjugate of z
public func conj<C:POComplex>(z:C) -> C { return z.conj }
/// norm of z
public func norm<C:POComplex>(z:C) -> C.RealType { return z.norm }
/// real part of z
public func real<C:POComplex>(z:C) -> C.RealType { return z.re }
/// imaginary part of z
public func imag<C:POComplex>(z:C) -> C.RealType { return z.im }
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
    public var i:GaussianInt<Self>{ return GaussianInt(self, 0) }
}
///
/// Complex Real
///
public protocol POComplexReal : POComplex {
    typealias RealType: POReal
}
extension POComplexReal {
    private typealias R = RealType
    public init(abs:R, arg:R) {
        self.init(abs * RealType.cos(arg), abs * RealType.sin(arg))
    }
    /// absolute value of `self`
    public var abs:R {
        get { return RealType.hypot(re, im) }
        set {
            let r = newValue / abs
            (re, im) = (re * r, im * r)
        }
    }
    /// argument of `self`
    public var arg:R  {
        get { return R.atan2(im, re) }
        set {
            let m = abs
            (re, im) = (m * R.cos(newValue), m * R.sin(newValue))
        }
    }
    /// projection of `self`
    public var proj:Self {
        if re.isFinite && im.isFinite {
            return self
        } else {
            return Self(
                R(1)/R(0), im.isSignMinus ? -R(0) : R(0)
            )
        }
    }
    public static func abs(z:Self)->R { return z.abs }
    public static func arg(z:Self)->R { return z.arg }
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
    public var i:Complex<Self>{ return Complex(self, 0) }
}
