//
//  porational.swift
//  pons
//
//  Created by Dan Kogai on 2/7/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

// add gcd()
public extension POInteger {
    /// GCD by Euclid's algorithm
    ///
    /// used to be default but gave way to binary algorithm
    ///
    /// - returns greatest common divisor of `lhs` and `rhs`
    public static func egcd(lhs: Self, _ rhs:Self)->Self {
        var (r, q) = lhs < rhs ? (lhs, rhs) : (rhs, lhs)
        while r > 0 {
            (q, r) = (r, q % r)
        }
        return q
    }
    /// GCD by binary algorithm
    ///
    /// cf . https://en.wikipedia.org/wiki/Binary_GCD_algorithm
    //
    /// - returns greatest common divisor of `lhs` and `rhs`
    public static func gcd(lhs: Self, _ rhs:Self)->Self {
        if lhs == 0 { return rhs }
        if rhs == 0 { return lhs }
        var (u, v) = (lhs, rhs)
        var twos = 0
        while (u | v) & 1 == 0 {
            u >>= 1
            v >>= 1
            twos += 1
        }
        while u & 1 == 0 {
            u >>= 1
        }
        repeat {    // u is odd
            while v & 1 == 0 {  // v is odd
                v >>= 1
            }
            if u > v { (u, v) = (v, u) } // keep u <= v
            v -= u
        } while v != 0
        return u << Self(twos)
    }
}
public protocol PORational : POReal {
    typealias IntType:POInt
    var sgn:Bool { get set }
    var num:IntType.UIntType { get set }
    var den:IntType.UIntType { get set }
    init(_:IntType, _:IntType, isNormal:Bool)
    init(_:Bool, _:IntType.UIntType, _:IntType.UIntType, isNormal:Bool)
}
public extension PORational {
    public var numerator:IntType   { return IntType(num) }
    public var denominator:IntType { return IntType(den) }
    public func toIntMax()->IntMax {
        return (sgn ? -1 : 1) * (num / den).toIntMax()
    }
    public var asIntType:IntType? {
        return self.toMixed().0
    }
    public func toMixed()->(IntType, Self) {
        let (u, f) = IntType.UIntType.divmod(num, den)
        var r = self
        r.num = f
        return ((self.isSignMinus ? -1 : 1) * IntType(u), r)
    }
    public func toDouble()->Double {
        if self.isZero {
            return self.isSignMinus ? -0.0 : +0.0
        }
        if self.isInfinite {
            return self.isSignMinus ? -Double.infinity : +Double.infinity
        }
        if self.isNaN {
            return Double.NaN
        }
        let msb = min(self.num.msbAt, self.den.msbAt)
        var n = self.num
        var d = self.den
        if msb > 64 {
            let shift = IntType.UIntType(msb + 1 - 64)
            n >>= shift
            d >>= shift
        }
        return Double(self.sgn ? -1 : 1) * n.toDouble() / d.toDouble()
    }
    public var isSignMinus:Bool { return sgn }
    public var isInfinite:Bool  { return den == 0 && num != 0 }
    public static var infinity:Self  { return Self(false, 1, 0, isNormal:true) }
    public var isNaN:Bool       { return den == 0 && num == 0 }
    public static var NaN:Self  { return Self(false, 0, 0, isNormal:true) }
    public var isZero:Bool      { return den != 0 && num == 0 }
    public static var zero:Self  { return Self(false, 0, 1, isNormal:true) }
    public func toString(base:Int = 10)-> String {
        let s = sgn ? "-" : ""
        return "\(s)(\(num.toString(base))/\(den.toString(base)))"
    }
    public var description:String {
        return self.toString()
    }
    public var hashValue:Int {
        let bits = sizeof(Int) * 4
        return (sgn ? -1 : 1) * (((num.hashValue >> bits) << bits) | (den.hashValue >> bits))
    }
    public mutating func truncate(bits:Int)->Self {
        if num == 0 {
            den = den == 0 ? 0 : 1
        } else if bits < self.precision + 1 {
            num <<= IntType.UIntType(bits)
            let (q, r) = IntType.UIntType.divmod(num, den)
            num = q
            if r * 2 >= den {  // round up
                num += IntType.UIntType(1)
            }
            if num == 0 {
                den = 1
            } else {
                den = IntType.UIntType(1) << IntType.UIntType(bits)
                while num & 1 == 0 {    // reduce if necessary
                    num >>= 1
                    den >>= 1
                }
            }
        }
        return self
    }
    public func divide(by:Self, precision:Int=64)->Self { return self / by }
    public static func multiplyWithOverflow(lhs:Self, _ rhs:Self)->(Self, overflow:Bool) {
        typealias U = IntType.UIntType
        if rhs.isZero { // +-infinity
            var n = lhs
            n.num = 1
            n.den = 0
            return (n, false)
        }
        if lhs.isZero { return (zero, false) }
        var ln = lhs.num, ld = lhs.den, rn = rhs.num, rd = rhs.den;
        let gn = U.gcd(ln, rd), gd = U.gcd(ld, rn);
        ln /= gn; rn /= gd;
        ld /= gd; rd /= gn;
        let (n, nof) = U.multiplyWithOverflow(ln, rn)
        let (d, dof) = U.multiplyWithOverflow(ld, rd)
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
        typealias U = IntType.UIntType
        if rhs.isZero { return (lhs, false) }
        if lhs.isZero { return (rhs, false) }
        if lhs == rhs { return (2 * lhs, false) }
        if lhs.den == rhs.den {
            let (n, o) = Bool.xor(lhs.sgn, rhs.sgn)
                ? lhs.num < rhs.num ? U.subtractWithOverflow(rhs.num, lhs.num)
                    : U.subtractWithOverflow(lhs.num, rhs.num)
                : U.addWithOverflow(lhs.num, rhs.num)
            if n == 0 { return (zero, false) }
            var r = lhs
            let g = U.gcd(n, lhs.den)
            r.sgn = lhs.num < rhs.num ? rhs.sgn: lhs.sgn
            r.num = n
            if g != 1 {
                r.num /= g
                r.den /= g
            }
            return (r, o)
        } else {
            let (ln, ol) = U.multiplyWithOverflow(lhs.num, rhs.den)
            let (rn, or) = U.multiplyWithOverflow(rhs.num, lhs.den)
            if Bool.xor(lhs.sgn, rhs.sgn) && ln == rn { return (zero, ol||or) }
            let (an, oa) = Bool.xor(lhs.sgn, rhs.sgn)
                ? ln < rn   ? U.subtractWithOverflow(rn, ln)
                            : U.subtractWithOverflow(ln, rn)
                : U.addWithOverflow(ln, rn)
            let (ad, od) = U.multiplyWithOverflow(lhs.den, rhs.den)
            let g = U.gcd(an, ad)
            var r = lhs
            r.sgn = ln < rn ? rhs.sgn: lhs.sgn
            r.num = an / g
            r.den = ad / g
            return (r, ol||or||oa||od)
        }
    }
    public static func subtractWithOverflow(lhs:Self, _ rhs:Self)->(Self, overflow:Bool) {
        return rhs.isZero ? (lhs, false) : addWithOverflow(lhs, -rhs)
    }
}
public struct Rational<I:POInt> : PORational, FloatLiteralConvertible {
    public typealias IntType = I
    public var sgn:Bool = false
    public var num:I.UIntType = 0
    public var den:I.UIntType = 1
    public var precision:Int {
        return I.self == BigInt.self
            ? Swift.max(32, max(num.msbAt, den.msbAt) + 1)
            : Swift.min(32, den.msbAt + 1)
    }
    public init(_ s:Bool, _ n:I.UIntType, _ d:I.UIntType, isNormal:Bool = false) {
        // print("\(__FILE__):\(__LINE__): n=\(n),d=\(d),isNormal=\(isNormal)")
        typealias U = IntType.UIntType
        (sgn, num, den) = isNormal ? (s, n, d)
            : n == 0 ? (s, 0, d != 0 ? 1 : 0)
            : d == 0 ? (s, 1, 0) : { (s, n/$0, d/$0) }(U.gcd(n, d))
    }
    public init(_ q:Rational<I>) {
        self.init(q.sgn, q.num, q.den, isNormal:false)
    }
    public init(_ n:IntType, _ d:IntType, isNormal:Bool = false) {
        self.init (
            Bool.xor(n.isSignMinus, d.isSignMinus),
            n.abs.asUnsigned!,
            d.abs.asUnsigned!
        )
    }
    public init(_ n:IntType) {
        self.init(n.isSignMinus, n.abs.asUnsigned!, 1)
    }
    public init(_ n:Int) {
        self.init(n < 0, IntType(n).abs.asUnsigned!, 1)
    }
    public init(_ r:Double) {
        let (m, e) = Double.frexp(r)
        // print("\(__FILE__):\(__LINE__): m=\(m),e=\(e)")
        let b = Swift.min(Double.precision, I.UIntType.precision - 1)
        let d = Swift.abs(m) * Double(1 << b)
        if m.isNaN {
            self.init(Rational.NaN)
        }
        else if m.isInfinite {
            self.init(m.isSignMinus ? -Rational.infinity : Rational.infinity)
        }
        else {
            typealias U = IntType.UIntType
            var n = U(d.abs)
            var d = U(1) << U(b)
            if e < 0    { d <<= U(-e) }
            else        { n <<= U(+e) }
            self.init(r.isSignMinus, n, d)
        }
    }
    public init(_ r:BigFloat) {
        if r.exponent < 0 {
            self.init( r.significand.over(BigInt(1) << BigInt(r.exponent) ) )
        } else {
            self.init( (r.significand << BigInt(r.exponent)).over(1) )
        }
    }
    public var asBigFloat:BigFloat? {
        return BigFloat(self.asBigRat!)
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
    public func frexp()->(Rational<I>, Int)   {
        var (n, d) = (num, den)
        let e = n.msbAt + 1 - d.msbAt
        if e < 0 {
            n <<= I.UIntType(-e)
        } else {
            d <<= I.UIntType(+e)
        }
        return (Rational<I>(self.sgn, n, d), e)
    }
    public static func frexp(q:Rational<I>)->(Rational<I>, Int) {
        return q.frexp()
    }
    public func ldexp(ex:Int)->Rational<I> {
        var (n, d) = (num, den)
        if ex < 0 {
            d <<= I.UIntType(-ex)
        } else {
            n <<= I.UIntType(+ex)
        }
        return Rational<I>(self.sgn, n, d)
    }
    public static func ldexp(q:Rational<I>, _ ex:Int)->Rational<I> {
        return q.ldexp(ex)
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
public func *<Q:PORational>(lhs:Q, rhs:Q.IntType) -> Q {
    return Q(Bool.xor(lhs.sgn, rhs.isSignMinus), lhs.num * rhs.abs.asUnsigned!, lhs.den, isNormal:false)
}
public func *<Q:PORational>(lhs:Q.IntType, rhs:Q) -> Q {
    return Q(Bool.xor(lhs.isSignMinus, rhs.sgn), lhs.abs.asUnsigned! * rhs.num, rhs.den, isNormal:false)
}
public func &*<Q:PORational>(lhs:Q, rhs:Q) -> Q {
    return Q.multiplyWithOverflow(lhs, rhs).0
}
public func /<Q:PORational>(lhs:Q, rhs:Q) -> Q {
    let (result, overflow) = Q.divideWithOverflow(lhs, rhs)
    if overflow { fatalError("\(lhs) / \(rhs) overflows") }
    return result
}
public func /<Q:PORational>(lhs:Q, rhs:Q.IntType) -> Q {
    return Q(Bool.xor(lhs.sgn, rhs.isSignMinus), lhs.num, lhs.den * rhs.abs.asUnsigned!, isNormal:false)
}
public func /<Q:PORational>(lhs:Q.IntType, rhs:Q) -> Q {
    return Q(Bool.xor(lhs.isSignMinus, rhs.sgn), rhs.num, lhs.abs.asUnsigned! * rhs.den, isNormal:false)
}
public func %<Q:PORational>(lhs:Q, rhs:Q) -> Q {
    let i = Q.divideWithOverflow(lhs, rhs).0.asIntType!
    return lhs - (rhs * i)
}
// add .toRational() and .asNational
public extension POInt {
    public func toRational(denominator:Self = 1)->Rational<Self> {
        return Rational(self, denominator)
    }
    public var asRational:Rational<Self>? {
        return self.toRational()
    }
    public func over(dominator:Self)->Rational<Self> {
        return self.toRational(dominator)
    }
}
/// BigRat = Rational<BigInt>
public typealias BigRat = Rational<BigInt>
///
public extension POReal {
    public init (_ q:BigRat) {
        // print("\(__FILE__):\(__LINE__): \(Self.self)(\(q) as \(BigRat.self))")
        self.init(q.toDouble())
    }
    ///
    public var asBigRat:BigRat? {
        return BigRat(self.toDouble())
    }
}
