//
//  porational.swift
//  pons
//
//  Created by Dan Kogai on 2/7/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

// add gcd()
public extension POInteger {
    public static func gcd(lhs: Self, _ rhs:Self)->Self {
        var (r, q) = lhs < rhs ? (lhs, rhs) : (rhs, lhs)
        if r == 0 { fatalError("To divide by zero, call Chuck Norris") }
        while r > 0 {
            (q, r) = (r, q % r)
        }
        return q
    }
}
// add .toRational() and .asNational
public extension POInt {
    public func toRational(denominator:Self = 1)->Rational<UIntType> {
        return Rational(
            Bool.xor(self.isSignMinus, denominator.isSignMinus),
            self.abs.asUnsigned,
            denominator.abs.asUnsigned
        )
    }
    public var asRational:Rational<Self.UIntType> {
        return self.toRational()
    }
}
public struct Rational<U:POUInt> : PONumber, IntegerLiteralConvertible {
    public init(integerLiteral:Int) {
        self.init(integerLiteral)
    }
    public typealias UIntType = U
    public var sgn:Bool = false
    public var num:U = 0
    public var den:U = 0
    public init(_ s:Bool, _ n:U, _ d:U, isNormal:Bool = false) {
        sgn = s
        let g = isNormal ? 1 : U.gcd(n, d)
        num = isNormal ? n : n / g
        den = isNormal ? n : d / g
    }
    public init(_ q:Rational<U>) {
        sgn = q.sgn
        num = q.num
        den = q.den
    }
    public init(_ n:Int, _ d:Int, isNormal:Bool = false) {
        self.init(Bool.xor(n.isSignMinus, d.isSignMinus), U(n), U(d), isNormal:isNormal)
    }
    public init(_ n:Int) {
        self.init(n, 1, isNormal:true)
    }
    public init(_ r:Double) {
        let (m, e) = Double.frexp(r)
        let n = unsafeBitCast(m, UInt64.self) | UInt64(0x000fffffffffffff) | (1 << 52)
        let d = UInt64(1 << (e - 1))
        self.init(r.isSignMinus, UIntType(n), UIntType(d))
    }
    public func toIntMax()->IntMax {
        return ((sgn ? -1 : 1) * num / den).toIntMax()
    }
    public func toDouble()->Double {
        return (sgn ? -1 : 1) * Double(num.toUIntMax()) / Double(den.toUIntMax())
    }
    public var description:String {
        let s = sgn ? "-" : ""
        return "(\(s)\(num)/\(den))"
    }
    public var hashValue:Int {
        let bits = sizeof(Int) * 4
        return (sgn ? -1 : 1) * (((num.hashValue >> bits) << bits) | (den.hashValue >> bits))
    }
    public var isSignMinus:Bool { return sgn }
    public var isInfinite:Bool  { return den == 0 && num != 0 }
    public var isNaN:Bool       { return den == 0 && num == 0 }
    public var isZero:Bool      { return den != 0 && num == 0 }
    public static func multiplyWithOverflow(lhs:Rational<U>, _ rhs:Rational<U>)->(Rational<U>, overflow:Bool) {
        var ln = lhs.num, ld = lhs.den, rn = rhs.num, rd = rhs.den;
        let gn = UIntType.gcd(ln, rd), gd = UIntType.gcd(ld, rn);
        ln /= gn; rn /= gd;
        ld /= gd; rd /= gn;
        let (n, nof) = U.multiplyWithOverflow(ln, rn)
        let (d, dof) = U.multiplyWithOverflow(ld, rd)
        var q = lhs
        q.sgn  = Bool.xor(lhs.sgn, rhs.sgn)
        q.num = n
        q.den = d
        return (q, overflow: nof || dof)
    }
    public var reciprocal:Rational<U> {
        var newValue = self
        (newValue.num, newValue.den) = (den, num)
        return newValue
    }
    public static func divideWithOverflow(lhs:Rational<U>, _ rhs:Rational<U>)->(Rational<U>, overflow:Bool) {
        return multiplyWithOverflow(lhs, rhs.reciprocal)
    }
    public static func addWithOverflow(lhs:Rational<U>, _ rhs:Rational<U>)->(Rational<U>, overflow:Bool) {
        if lhs.den == rhs.den {
            let (n, nof) = Bool.xor(lhs.sgn, rhs.sgn)
                ? lhs.num < rhs.num ? UIntType.subtractWithOverflow(rhs.num, lhs.num)
                    : UIntType.subtractWithOverflow(lhs.num, rhs.num)
                : UIntType.addWithOverflow(lhs.num, rhs.num)
            return (Rational(lhs.num < rhs.num ? rhs.sgn: lhs.sgn, n, lhs.den), overflow:nof)
        } else {
            var l = lhs, r = rhs
            // print("add:", l, r)
            let g = U.gcd(lhs.den, rhs.den)
            let d = l.den * r.den / g
            l.num *= r.den / g
            r.num *= l.den / g
            l.den = d
            r.den = d
            // print("add:", l, r)
            return addWithOverflow(l, r)
        }
    }
    public static func subtractWithOverflow(lhs:Rational<U>, _ rhs:Rational<U>)->(Rational<U>, overflow:Bool) {
        return addWithOverflow(lhs, -rhs)
    }
}
public func ==<U:POUInt>(lhs:Rational<U>, rhs:Rational<U>) -> Bool {
    return !lhs.isNaN && !rhs.isNaN
        && lhs.sgn == rhs.sgn && lhs.num == rhs.num && lhs.den == rhs.den
}
public func < <U:POUInt>(lhs:Rational<U>, rhs:Rational<U>) -> Bool {
    return (lhs - rhs).sgn
}
public prefix func +<U:POUInt>(q:Rational<U>) -> Rational<U> {
    return q
}
public prefix func -<U:POUInt>(q:Rational<U>) -> Rational<U> {
    var newValue = q
    newValue.sgn = !q.sgn
    return newValue
}
public func +<U:POUInt>(lhs:Rational<U>, rhs:Rational<U>) -> Rational<U> {
    let (result, overflow) = Rational<U>.addWithOverflow(lhs, rhs)
    if overflow { fatalError("\(lhs) + \(rhs) overflows") }
    return result
}
public func &+<U:POUInt>(lhs:Rational<U>, rhs:Rational<U>) -> Rational<U> {
    return Rational<U>.addWithOverflow(lhs, rhs).0
}
public func -<U:POUInt>(lhs:Rational<U>, rhs:Rational<U>) -> Rational<U> {
    let (result, overflow) = Rational<U>.subtractWithOverflow(lhs, rhs)
    if overflow { fatalError("\(lhs) - \(rhs) overflows") }
    return result
}
public func &-<U:POUInt>(lhs:Rational<U>, rhs:Rational<U>) -> Rational<U> {
    return Rational<U>.subtractWithOverflow(lhs, rhs).0
}
public func *<U:POUInt>(lhs:Rational<U>, rhs:Rational<U>) -> Rational<U> {
    let (result, overflow) = Rational<U>.multiplyWithOverflow(lhs, rhs)
    if overflow { fatalError("\(lhs) * \(rhs) overflows") }
    return result
}
public func &*<U:POUInt>(lhs:Rational<U>, rhs:Rational<U>) -> Rational<U> {
    return Rational<U>.multiplyWithOverflow(lhs, rhs).0
}
public func /<U:POUInt>(lhs:Rational<U>, rhs:Rational<U>) -> Rational<U> {
    let (result, overflow) = Rational<U>.divideWithOverflow(lhs, rhs)
    if overflow { fatalError("\(lhs) / \(rhs) overflows") }
    return result
}
infix operator &/ {associativity left precedence 150}
public func &/<U:POUInt>(lhs:Rational<U>, rhs:Rational<U>) -> Rational<U> {
    return Rational<U>.multiplyWithOverflow(lhs, rhs).0
}
