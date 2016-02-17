//
//  pobigfloat.swift
//  test
//
//  Created by Dan Kogai on 2/17/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

public struct BigFloat : IntegerLiteralConvertible, FloatLiteralConvertible {
    public var significand:BigInt = 0
    public var exponent:Int = 0
    public init(significand:BigInt, exponent:Int) {
        self.significand = significand
        self.exponent = exponent
    }
    public init(_ bi:BigInt) {
        var (s, e) = (bi, 0)
        while s != 0 && s & 1 == 0 {
            s >>= 1
            e += 1
        }
        significand = s
        exponent = e
    }
    public init(_ bf:BigFloat) {
        significand = bf.significand
        exponent = bf.exponent
    }
    public init(_ i:Int) {
        var (s, e) = (i, 0)
        while s != 0 && s & 1 == 0 {
            s >>= 1
            e += 1
        }
        significand = s.asBigInt!
        exponent = e
    }
    public init(_ d:Double) {
        if d.isZero {
            exponent = 0
            significand = BigInt(d)
        } else {
            let (m, e) = Double.frexp(d)
            if Swift.abs(m) == 0.5 {
                significand = m < 0 ? -1 : 1
                exponent = e - 1
            } else {
                var s = Int(Double.ldexp(d, Double.precision))
                // print("d=\(d), m=\(m), e=\(e), s=\(s)")
                exponent = e - s.abs.msbAt - 1
                while s != 0 && s & 1 == 0 {
                    s >>= 1
                    exponent += 1
                }
                significand = s.asBigInt!
            }
        }
    }
    public var asBigRat:BigRat? {
        if self.isNaN { return BigRat.NaN }
        if self.isInfinite { return self.isSignMinus ? -BigRat.infinity : BigRat.infinity }
        if self.isZero { return self.isSignMinus ? -BigRat.zero : BigRat.zero }
        var num = BigInt(self.significand)
        var den = BigInt(1)
        if exponent < 0 {
            den <<= BigInt(-exponent)
        } else {
            num <<= BigInt(+exponent)
        }
        return num.over(den)
    }
    // IntegerLiteralConvertible
    public typealias IntegerLiteralType = Int.IntegerLiteralType
    public init(integerLiteral:IntegerLiteralType) {
        self.init(integerLiteral)
    }
    // FloatLiteralConvertible
    public typealias FloatLiteralType = Double.FloatLiteralType
    public init(floatLiteral:FloatLiteralType) {
        self.init(floatLiteral)
    }
    public var precision:Int {
        return significand.msbAt + 1
    }
    public var isSignMinus:Bool {
        return significand.isSignMinus
    }
    public var isZero:Bool {
        return significand == 0 && exponent.abs < Int.max
    }
    public var isInfinite:Bool {
        return significand == 0 && exponent.abs == Int.max
    }
    public var isFinite:Bool {
        return !self.isInfinite
    }
    public static let infinity = BigFloat(significand:0, exponent:Int.max)
    public var isNaN:Bool {
        return significand != 0 && exponent.abs == Int.max
    }
    public static let NaN = BigFloat(significand:1, exponent:Int.max)
    public static var isSignaling:Bool {
        return false
    }
    public var isNormal:Bool {
        return true
    }
    public var isSubnormal:Bool {
        return false
    }
    public var floatingPointClass:FloatingPointClassification {
        if self.isNaN {
            return .QuietNaN
        }
        if self.isInfinite {
            return self.isSignMinus ? .PositiveInfinity : .NegativeInfinity
        }
        if self.isZero {
            return self.isSignMinus ? .NegativeZero : .PositiveZero
        }
        return self.isSignMinus ? .NegativeNormal : .PositiveNormal
    }
    public func toDouble()->Double {
        return Double.ldexp(significand.toDouble(), exponent)
    }
    public mutating func truncate(bits:Int)->BigFloat {
        if self == 0 { return self }
        let shift = self.precision - bits
        if shift <= 0 { return self }
        let carry = self.significand.unsignedValue[shift - 1]
        self.significand >>= BigInt(shift)
        self.exponent += self.exponent < 0 ? -shift : shift
        if carry == .One { self.significand += 1}
        return self
    }
    public var reciprocal:BigFloat {
        if self.significand == 1 {  // just reverse the exponent
            return BigFloat(significand:1, exponent:-self.exponent)
        }
        return BigFloat(
            significand:self.significand.reciprocal(self.precision),
            exponent: -self.exponent - 2*self.precision
        )
    }
}
public func ==(lhs:BigFloat, rhs:BigFloat)->Bool {
    return lhs.significand == rhs.significand && lhs.exponent == rhs.exponent
}
public func <(lhs:BigFloat, rhs:BigFloat)->Bool {
    if lhs.significand.isSignMinus != rhs.significand.isSignMinus {
        return lhs.significand < rhs.significand
    }
    if lhs.exponent != rhs.exponent {
        return lhs.isSignMinus ? rhs.exponent < lhs.exponent : lhs.exponent < rhs.exponent
    }
    return lhs.significand < rhs.significand
}
public func *(lhs:BigFloat, rhs:BigFloat)->BigFloat {
    if lhs == 0 || rhs == 0 { return 0 }
    let sm = lhs.significand * rhs.significand
    let shift = sm.msbAt - (lhs.significand.msbAt + rhs.significand.msbAt)
    var ex = lhs.exponent + rhs.exponent
    ex += ex < 0 ? -shift : shift
    return BigFloat(significand:sm, exponent:ex)
}
public func /(lhs:BigFloat, rhs:BigFloat)->BigFloat {
    if lhs.significand.abs == rhs.significand.abs {
        let sig = Bool.xor(lhs.isSignMinus, rhs.isSignMinus) ? -1 : 1
        let ex  = lhs.exponent - rhs.exponent
        return BigFloat(significand:BigInt(sig), exponent:ex)
    }
    return lhs * rhs.reciprocal
}
