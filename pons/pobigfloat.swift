//
//  pobigfloat.swift
//  test
//
//  Created by Dan Kogai on 2/17/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

public struct BigFloat : POFloat, FloatLiteralConvertible {
    public typealias IntType = BigInt
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
        // print("significand = \(significand), exponent=\(exponent)")
        if d.isZero {
            exponent = 0
            significand = BigInt(d)
        } else if d.isInfinite {
            exponent =    BigFloat.infinity.exponent
            significand = (d.isSignMinus ? -BigFloat.infinity : +BigFloat.infinity).significand
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
    public var asIntType:BigInt? {
        return BigInt(self)
    }
    public func toIntMax()->IntMax {
        return BigInt(self).toIntMax()
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
        return significand.unsignedValue == 0 && exponent.abs < Int.max
    }
    public var isInfinite:Bool {
        return significand.unsignedValue == 0 && exponent.abs == Int.max
    }
    public var isFinite:Bool {
        return !self.isInfinite
    }
    public static let infinity = BigFloat(significand:0, exponent:Int.max)
    public var isNaN:Bool {
        return significand.unsignedValue != 0 && exponent.abs == Int.max
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
        if self.isNaN { return Double.NaN }
        if self.isInfinite { return self.isSignMinus ? -Double.infinity : +Double.infinity }
        return Double.ldexp(significand.toDouble(), exponent)
    }
    public mutating func truncate(bits:Int)->BigFloat {
        if self == 0 { return self }
        let shift = self.precision - bits
        if shift <= 0 { return self }
        let ex = self.exponent + (self.significand.msbAt + 1)
        let carry = self.significand.unsignedValue[shift - 1]
        self.significand >>= BigInt(shift)
        if carry == .One { self.significand.unsignedValue += 1}
        self.exponent = ex - self.significand.msbAt - 1
        while self.significand != 0 && self.significand & 1 == 0 {
            self.significand >>= 1
            self.exponent    += 1
        }
        return self
    }
    public func divide(by:BigFloat, precision:Int=32)->BigFloat {
        if self.significand.abs == by.significand.abs {
            let sig = Bool.xor(self.isSignMinus, by.isSignMinus) ? -1 : 1
            let ex  = self.exponent - by.exponent
            return BigFloat(significand:BigInt(sig), exponent:ex)
        }
        return self * by.reciprocal(precision)
    }
    public func reciprocal(precision:Int=32)->BigFloat {
        if self.isZero  { // zero or infinity
            return self.isSignMinus ? -BigFloat.infinity : +BigFloat.infinity
        }
        if self.isInfinite {
            return self.isSignMinus ? BigFloat(-0.0) : BigFloat(+0.0)
        }
        if self.isNaN { return self }
        if self.significand == 1 {  // just reverse the exponent
            return BigFloat(significand:1, exponent:-self.exponent)
        }
        let ex = self.exponent + (self.significand.msbAt + 1)
        let px = max(self.precision, precision)
        let n = BigInt(1) << BigInt(px*2)
        let q = n / self.significand
        return BigFloat(significand:q, exponent:(-ex - q.msbAt))
    }
    public var abs:BigFloat {
        return self.isSignMinus ? -self : self
    }
    public static func abs(bf:BigFloat)->BigFloat {
        return bf.abs
    }
    public func toMixed()->(BigInt, BigFloat) {
        let i = BigInt(self)
        return (i, self - BigFloat(i))
    }
}
public extension BigInt {
    public init(_ bf:BigFloat) {
        if 0 <= bf.exponent {
            self.init(bf.significand << BigInt(bf.exponent))
        } else if -bf.exponent <= bf.significand.msbAt {
            self.init(bf.significand >> BigInt(-bf.exponent))
        } else {
            self.init(0)
        }
    }
}
public func ==(lhs:BigFloat, rhs:BigFloat)->Bool {
    return lhs.significand == rhs.significand && lhs.exponent == rhs.exponent
}
public func <(lhs:BigFloat, rhs:BigFloat)->Bool {
    return (lhs - rhs).isSignMinus
}
public func *(lhs:BigFloat, rhs:BigFloat)->BigFloat {
    // if lhs == 0 || rhs == 0 { return 0 }
    let xl = lhs.exponent + lhs.significand.msbAt
    let xr = rhs.exponent + rhs.significand.msbAt
    let sig = lhs.significand * rhs.significand
    let shift  = sig.msbAt - (lhs.significand.msbAt + rhs.significand.msbAt)
    // print("shift=\(shift),xl=\(xl), xr=\(xr), sig=\(sig)")
    return BigFloat(significand:sig, exponent: xl + xr - sig.msbAt + shift)
}
public func /(lhs:BigFloat, rhs:BigFloat)->BigFloat {
    return lhs.divide(rhs)
}
public func %(lhs:BigFloat, rhs:BigFloat)->BigFloat {
    let f = BigFloat(lhs / rhs).toMixed().1
    return rhs * f
}
public prefix func +(bf:BigFloat)->BigFloat {
    return bf
}
public prefix func -(bf:BigFloat)->BigFloat {
    return BigFloat(significand:-bf.significand, exponent:bf.exponent)
}
public func +(lhs:BigFloat, rhs:BigFloat)->BigFloat {
    var (ls, rs) = (lhs.significand, rhs.significand)
    let dx = lhs.exponent - rhs.exponent
    if dx < 0  {
        rs <<= BigInt(-dx)
    } else if dx > 0  {
        ls <<= BigInt(+dx)
    }
    let ex = max(lhs.exponent, rhs.exponent)
    let sig = ls + rs
    // if sig.msbAt > ex // { ex -print("sig.msbAt = \(sig.msbAt), ls.msbAt = \(ls.msbAt), rs.msbAt = \(rs.msbAt)")
    return BigFloat(significand:sig, exponent:ex - Swift.abs(dx))
}
public func -(lhs:BigFloat, rhs:BigFloat)->BigFloat {
    return lhs + (-rhs)
}
