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
    public func over(dominator:Self)->Rational<UIntType> {
        return self.toRational(dominator)
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
    public func toIntMax()->IntMax {
        return ((sgn ? -1 : 1) * num / den).toIntMax()
    }
    public func toDouble()->Double {
        return (sgn ? -1 : 1) * Double(num.toUIntMax()) / Double(den.toUIntMax())
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
            var result = lhs
            result.sgn = lhs.num < rhs.num ? rhs.sgn: lhs.sgn
            result.num = n
            return (result, overflow:nof)
        } else {
            var l = lhs, r = rhs
            var (o0, o1, o2, o3) = (false, false, false, false)
            var d = UIntType(0), fin = lhs
            // print("add:", l, r)
            let g = UIntType.gcd(lhs.den, rhs.den)
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
        let n = unsafeBitCast(m, UInt64.self) | UInt64(0x001f_ffff_ffff_ffff)
        let d = UInt64(1 << (e - 1))
        self.init(r.isSignMinus, UIntType(n), UIntType(d))
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
infix operator &/ {associativity left precedence 150}
public func &/<Q:PORational>(lhs:Q, rhs:Q) -> Q {
    return Q.multiplyWithOverflow(lhs, rhs).0
}
