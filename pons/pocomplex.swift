//
//  pocomplex.swift
//  pons
//
//  Created by Dan Kogai on 2/6/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

public protocol POComplex: PONumber {
    typealias RealType:POSignedNumber
    var re:RealType { get }
    var im:RealType { get }
    init(_:RealType, _:RealType)
}
extension POComplex {
    public init() {
        self.init(0, 0)
    }
    public init(_ r :RealType) {
        self.init(r, 0)
    }
    public func toIntMax()->IntMax {
        guard im == 0 else {
            fatalError("imag == \(im) != 0")
        }
        return re.toIntMax()
    }
    public var conj:Self {
        return Self(re, -im)
    }
    public var norm:RealType {
        return re*re + im*im
    }
    public var i:Self {
        return Self(im, re)
    }
}
public func ==<C:POComplex>(lhs:C, rhs:C)->Bool {
    return lhs.re == rhs.re && lhs.im == rhs.im
}
public prefix func -<C:POComplex>(z:C)->C {
    return C(-z.re, -z.im)
}
public prefix func +<C:POComplex>(z:C)->C {
    return z
}
public func +<C:POComplex>(lhs:C, rhs:C)->C {
    return C(lhs.re + rhs.re, lhs.im + rhs.im)
}
public func -<C:POComplex>(lhs:C, rhs:C)->C {
    return C(lhs.re - rhs.re, lhs.im - rhs.im)
}
public func *<C:POComplex>(lhs:C, rhs:C)->C {
    return C(
        lhs.re*rhs.re - lhs.im*rhs.im,
        lhs.re*rhs.im + lhs.im*rhs.re
    )
}
public func /<C:POComplex>(lhs:C, rhs:C)->C {
    let numer = lhs * rhs.conj
    let denom = rhs.norm
    return C(numer.re / denom, numer.im / denom)
}

//public struct GaussianInt<I:POInt> : POComplex {
//    public typealias RealType = I
//    public var real:I
//    public var imag:I
//    public init(_ r:I, _ i:I) {
//        real = r
//        imag = i
//    }
//    public var re:I { return real }
//    // public var im:I { return imag }
//}
//public extension POInt {
//    var i:GaussianInt<Self> {
//        return GaussianInt(0, self)
//    }
//}