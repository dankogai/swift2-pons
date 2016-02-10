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
public protocol PORational : POReal {
    typealias UIntType:POUInt
    var sgn:Bool { get set }
    var num:UIntType { get set }
    var den:UIntType { get set }
    init(_:Bool, _:UIntType, _:UIntType, isNormal:Bool)
}
public extension PORational {
    public var numerator:UIntType   { return num }
    public var denominator:UIntType { return den }
    public static var precision:Int {
        return UIntType.precision
    }
    public func toIntMax()->IntMax {
        return (sgn ? -1 : 1) * (num / den).toIntMax()
    }
    public func toMixed()->(UIntType.IntType, Self) {
        let i = (num / den).asSigned!
        var f = self
        f.num %= den
        return (sgn ? -i : i, f)
    }
    public func toDouble()->Double {
        let (i, f) = self.toMixed()
        return Double(i.toIntMax()) + Double(f.sgn ? -1 : 1) * f.num.toDouble() / f.den.toDouble()
    }
    public var isSignMinus:Bool { return sgn }
    public var isInfinite:Bool  { return den == 0 && num != 0 }
    public static var infinity:Self  { return Self(false, 1, 0, isNormal:true) }
    public var isNaN:Bool       { return den == 0 && num == 0 }
    public static var NaN:Self  { return Self(false, 0, 0, isNormal:true) }
    public var isZero:Bool      { return den != 0 && num == 0 }
    public static var zero:Self  { return Self(false, 0, 1, isNormal:true) }
    public var description:String {
        let s = sgn ? "-" : ""
        return "\(s)(\(num)/\(den))"
    }
    public var hashValue:Int {
        let bits = sizeof(Int) * 4
        return (sgn ? -1 : 1) * (((num.hashValue >> bits) << bits) | (den.hashValue >> bits))
    }
    public static func multiplyWithOverflow(lhs:Self, _ rhs:Self)->(Self, overflow:Bool) {
        if lhs.isZero || rhs.isZero { return (zero, false) }
        var ln = lhs.num, ld = lhs.den, rn = rhs.num, rd = rhs.den;
        let gn = UIntType.gcd(ln, rd), gd = UIntType.gcd(ld, rn);
        ln /= gn; rn /= gd;
        ld /= gd; rd /= gn;
        let (n, nof) = UIntType.multiplyWithOverflow(ln, rn)
        let (d, dof) = UIntType.multiplyWithOverflow(ld, rd)
        return (Self(Bool.xor(lhs.sgn, rhs.sgn), n, d, isNormal:true), overflow: nof || dof)
    }
    public var reciprocal:Self {
        var newValue = self
        (newValue.num, newValue.den) = (den, num)
        return newValue
    }
    public static func divideWithOverflow(lhs:Self, _ rhs:Self)->(Self, overflow:Bool) {
        return multiplyWithOverflow(lhs, rhs.reciprocal)
    }
    public static func addWithOverflow(lhs:Self, _ rhs:Self)->(Self, overflow:Bool) {
        if lhs.den == rhs.den {
            let (n, nof) = Bool.xor(lhs.sgn, rhs.sgn)
                ? lhs.num < rhs.num ? UIntType.subtractWithOverflow(rhs.num, lhs.num)
                    : UIntType.subtractWithOverflow(lhs.num, rhs.num)
                    : UIntType.addWithOverflow(lhs.num, rhs.num)
            if n == 0 { return (zero, false) }
            var result = lhs
            let g = UIntType.gcd(n, lhs.den)
            result.sgn = lhs.num < rhs.num ? rhs.sgn: lhs.sgn
            result.num = g == 1 ? n : n / g
            if g == 1 { result.den /= g }
            return (result, overflow:nof)
        } else {
            var l = lhs, r = rhs
            var (o0, o1, o2, o3) = (false, false, false, false)
            var d = UIntType(0), fin = lhs
            // print("add:", l, r)
            let g = UIntType.gcd(lhs.den, rhs.den)
            // print("__FILE__:__LINE__:", g)
            (d, o0) = UIntType.multiplyWithOverflow(l.den, r.den / g)
            (l.num, o1) = UIntType.multiplyWithOverflow(l.num, r.den / g)
            (r.num, o2) = UIntType.multiplyWithOverflow(r.num, l.den / g)
            l.den = d ; r.den = d
            // print("add:", l, r)
            (fin, o3) = addWithOverflow(l, r)
            return (fin, overflow: o0 || o1 || o2 || o3)
        }
    }
    public static func subtractWithOverflow(lhs:Self, _ rhs:Self)->(Self, overflow:Bool) {
        return addWithOverflow(lhs, -rhs)
    }
}
public struct Rational<U:POUInt> : PORational {
    public typealias UIntType = U
    public var sgn:Bool = false
    public var num:U = 0
    public var den:U = 1
    public init(_ s:Bool, _ n:U, _ d:U, isNormal:Bool = false) {
        // print("\(__FILE__):\(__LINE__): n=\(n),d=\(d),isNormal=\(isNormal)")
        (sgn, num, den) = isNormal ? (s, n, d)
            : n == 0 ? (s, 0, d != 0 ? 1 : 0)
            : d == 0 ? (s, 1, 0) : { (s, n/$0, d/$0) }(U.gcd(n, d))
    }
    public init(_ q:Rational<U>) {
        (sgn, num, den) = (q.sgn, q.num, q.den)
    }
    public init(_ n:Int, _ d:Int, isNormal:Bool = false) {
        self.init(Bool.xor(n.isSignMinus, d.isSignMinus), U(n), U(d), isNormal:isNormal)
    }
    public init(_ n:Int) {
        self.init(n, 1, isNormal:true)
    }
    public init(_ r:Double) {
        let (m, e) = Double.frexp(r)
        // print("\(__FILE__):\(__LINE__): m=\(m),e=\(e)")
        let b = Swift.min(Double.precision, UIntType.precision - 1)
        let n = UInt64(m * Double(1 << b))
        self.init(r.isSignMinus, UIntType(n), UIntType(1 << b))
        if e < 0    { self.den <<= UIntType(abs(e)) }
        else        { self.num <<= UIntType(abs(e)) }
    }
    // IntegerLiteralConvertible
    public typealias IntegerLiteralType = Int.IntegerLiteralType
    public init(integerLiteral:IntegerLiteralType) {
        self.init(integerLiteral)
    }
}
public func ==<Q:PORational>(lhs:Q, rhs:Q) -> Bool {
    return !lhs.isNaN && !rhs.isNaN
        && lhs.sgn == rhs.sgn && lhs.num == rhs.num && lhs.den == rhs.den
}
public func < <Q:PORational>(lhs:Q, rhs:Q) -> Bool {
    return (lhs - rhs).sgn
}
public prefix func +<Q:PORational>(q:Q) -> Q {
    return q
}
public prefix func -<Q:PORational>(q:Q) -> Q {
    return Q(!q.sgn, q.num, q.den, isNormal:true)
}
public func +<Q:PORational>(lhs:Q, rhs:Q) -> Q {
    let (result, overflow) = Q.addWithOverflow(lhs, rhs)
    if overflow { fatalError("\(lhs) + \(rhs) overflows") }
    return result
}
public func &+<Q:PORational>(lhs:Q, rhs:Q) -> Q {
    return Q.addWithOverflow(lhs, rhs).0
}
public func -<Q:PORational>(lhs:Q, rhs:Q) -> Q {
    let (result, overflow) = Q.subtractWithOverflow(lhs, rhs)
    if overflow { fatalError("\(lhs) - \(rhs) overflows") }
    return result
}
public func &-<Q:PORational>(lhs:Q, rhs:Q) -> Q {
    return Q.subtractWithOverflow(lhs, rhs).0
}
public func *<Q:PORational>(lhs:Q, rhs:Q) -> Q {
    let (result, overflow) = Q.multiplyWithOverflow(lhs, rhs)
    if overflow { fatalError("\(lhs) * \(rhs) overflows") }
    return result
}
public func &*<Q:PORational>(lhs:Q, rhs:Q) -> Q {
    return Q.multiplyWithOverflow(lhs, rhs).0
}
public func /<Q:PORational>(lhs:Q, rhs:Q) -> Q {
    let (result, overflow) = Q.divideWithOverflow(lhs, rhs)
    if overflow { fatalError("\(lhs) / \(rhs) overflows") }
    return result
}
// add .toRational() and .asNational
public extension POInt {
    public func toRational(denominator:Self = 1)->Rational<UIntType> {
        return Rational(
            Bool.xor(self.isSignMinus, denominator.isSignMinus),
            self.abs.asUnsigned!,
            denominator.abs.asUnsigned!
        )
    }
    public var asRational:Rational<Self.UIntType> {
        return self.toRational()
    }
    public func over(dominator:Self)->Rational<UIntType> {
        return self.toRational(dominator)
    }
}
