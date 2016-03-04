//
//  xtra_prime.swift
//  pons
//
//  Created by Dan Kogai on 2/9/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

public extension POUtil {
    public class Prime : SequenceType {
        public init(){}
     }
}
public extension POUtil.Prime {
    /// stream of primes
    public func generate()->AnyGenerator<BigInt> {
        var currPrime = BigInt(0)
        return anyGenerator {
            if let nextPrime = currPrime.nextPrime {
                currPrime = nextPrime
                return currPrime
            }
            return nil
        }
    }
    /// primes less than 256
    public static let tinyPrimes:[Int] = {
        var ps = [2, 3]
        var n = 5
        while n < 256 {
            for p in ps {
                if n % p == 0 { break }
                if p * p > n  { ps.append(n); break }
            }
            n += 2
        }
        return ps
    }()
    /// ### [A014233]
    ///
    /// Smallest odd number for which Miller-Rabin primality test
    /// on bases <= n-th prime does not reveal compositeness.
    ///
    /// [A014233]: https://oeis.org/A014233
    public static let A014233:[UIntMax] = [
        2047,                   // p0   = 2
        1373653,                // p1   = 3
        25326001,               // p2   = 5
        3215031751,             // p3   = 7
        2152302898747,          // p4   = 11
        3474749660383,          // p5   = 13
        341550071728321,        // p6   = 17
        341550071728321,        // p7   = 19
        3825123056546413051,    // p8   = 23
        3825123056546413051,    // p9   = 29
        3825123056546413051,    // p10  = 31
        0                       // p11  = 37; 318665857834031151167461  > UInt.max
    ]
}
//
//  Primarity Test
//
public extension POUInt {
    /// `true` if `self` passes the [Miller-Rabin] test on `base`.  `false` otherwise.
    ///
    /// [Miller-Rabin]: https://en.wikipedia.org/wiki/Miller%E2%80%93Rabin_primality_test
    public func millerRabinTest(base:Int)->Bool {
        if self < 2      { return false }
        if self & 1 == 0 { return self == 2 }
        var d = self - 1
        while d & 1 == 0 { d >>= 1 }
        var t = d
        var y = Self.powmod(Self(base), t, mod:self)
        //var y = Self.powmod(Self(base), t, self)
        // print("\(__FILE__):\(__LINE__): base=\(base),\nself=\(self),\ny=\(y)\nt=\(t)")
        while t != self-1 && y != 1 && y != self-1 {
            // y = (y * y) % self
            y = Self.mulmod(y, y, mod:self)
            t <<= 1
        }
        // print("\(__FILE__):\(__LINE__): base=\(base),self=\(self),y=\(y),t=\(t)")
        return y == self-1 || t & 1 == 1
    }
    /// [Lucas–Lehmer primality test] on `self`
    ///
    /// [Lucas–Lehmer primality test]: https://en.wikipedia.org/wiki/Lucas%E2%80%93Lehmer_primality_test
    /// - returns: `true` if Mersenne Prime, `false` if not. Oe `nil` if self is not even a Mersenne Number.
    public var isMersennePrime:Bool? {
        let p = Self(min(self.msbAt + 1, Self.precision - 1)) // mersenne number = number of bits
        // print("\(__FILE__):\(__LINE__): p = \(p), self = \(self)")
        guard self == Self(1)<<p - 1 else {
            return nil  // self is not 2**n - 1
        }
        guard p.isPrime else {  // if n is composite, so is Mn
            return false
        }
        var s:BigUInt = 4
        let d = self.asBigUInt!
        for _ in 0..<(p-2) {
            s = (s * s - 2) % d // BigUInt is used to avoid overflow at s * s
        }
        return s == 0
    }
    public func jacobiSymbol(i:Int)->Int {
        var m = self
        var j = 1
        var n = Self(i.abs)
        if (m <= 0 || m % 2 == 0) { return 0 }
        if (i < 0 && m % 4 == 3) { j = -j }
        while (n != 0) {
            while (n % 2 == 0) {
                n >>= 1
                if (m % 8 == 3 || m % 8 == 5 )  { j = -j }
            }
            (m, n) = (n, m)
            if (n % 4 == 3 && m % 4 == 3)  { j = -j }
            n %=  m
        }
        return (m == 1) ? j : 0
    }
    /// `true` if `self` is [Lucas pseudoprime]. `false` otherwise.
    ///
    /// [Lucas pseudoprime]: https://en.wikipedia.org/wiki/Lucas_pseudoprime
    public var isLucasProbablePrime:Bool {
        // make sure self is not a perfect square
        let r = Self.sqrt(self)
        if r*r == self { return false }
        let d:Int = {
            var d = 1
            for i in 2...256 {  // 256 is arbitrary
                d = (i & 1 == 0 ? 1 : -1) * (2 * i + 1)
                if self.jacobiSymbol(d) == -1 { return d }
            }
            fatalError("no such d found that self.jacobiSymbol(d) == -1")
        }()
        let p = 1
        var q = BigInt(1 - d) / 4
        // print("p = \(p), q = \(q)")
        var n = (self.asBigInt! + 1) / 2
        // print("n = \(n)")
        var (u, v) = (BigInt(0), BigInt(2))
        var (u2, v2) = (BigInt(1), p.asBigInt!)
        var q2 = 2*q
        let (bs, bd) = (self.asBigInt!, d.asBigInt!)
        while 0 < n {
            // u2 = (u2 * v2) % bs
            u2 *= v2
            u2 %= bs
            // v2 = (v2 * v2 - q2) % bs
            v2 *= v2
            v2 -= q2
            v2 %= bs
            if n & 1 == 1 {
                let t = u
                // u = u2 * v + u * v2
                u *= v2
                u += u2 * v
                u += u & 1 == 0 ? 0 : bs
                // u = (u / 2) % bs
                u /= 2
                u %= bs
                // v = (v2 * v) + (u2 * t * bd)
                v *= v2
                v += u2 * t * bd
                v += v & 1 == 0 ? 0 : bs
                // v = (v / 2) % bs
                v /= 2
                v %= bs
            }
            // q = (q * q) % bs
            q *= q
            q %= bs
            // q2 = q + q
            q2 = q << 1
            // print(u, v)
            n >>= 1
        }
        return u == 0
    }
    /// true if `self` is prime according to the BPSW primarity test
    ///
    /// https://en.wikipedia.org/wiki/Baillie–PSW_primality_test
    public var isPrime:Bool {
        if self < 2      { return false }
        if self & 1 == 0 { return self == 2 }
        if self % 3 == 0 { return self == 3 }
        if self % 5 == 0 { return self == 5 }
        if self % 7 == 0 { return self == 7 }
        return self.millerRabinTest(2) && self.isLucasProbablePrime
    }
    public var nextPrime:Self? {
        if self < 2 { return 2 }
        var (u, o):(Self, Bool)
        (u, o) = Self.addWithOverflow(self, self & 1 == 0 ? 1 : 2)
        if o { return nil }
        while !u.isPrime {
            (u, o) = Self.addWithOverflow(u, 2)
            if o { return nil }
        }
        return u
    }
    public var prevPrime:Self? {
        if self <= 2 { return nil }
        if self == 3 { return 2 }
        var u = self - (self & 1 == 0 ? 1 : 2)
        while !u.isPrime {
            u = u - 2
        }
        return u
    }
}
//
// Prime Factorization
//
public extension POUtil.Prime {
    // cf.
    //   http://en.wikipedia.org/wiki/Shanks'_square_forms_factorization
    //   https://github.com/danaj/Math-Prime-Util/blob/master/factor.c
    public static let squfofMultipliers:[UIntMax] = [
        1,      3,      5,      7,      11,
        3*5,    3*7,    3*11,   5*7,    5*11,
        7*11,   3*5*7,  3*5*11, 3*7*11, 5*7*11, 3*5*7*11
    ]
}
public extension UIntMax {
    public static func squfof_one(n:UIntMax, _ k:UIntMax)->UIntMax {
        // print("n=\(n),k=\(k)")
        if n < 2      { return 1 }
        if n & 1 == 0 { return 2 }
        let rn = UIntMax.sqrt(n)
        if rn * rn == n { return rn }
        let kn = IntMax(k) &* IntMax(n)
        let rkn = IntMax.sqrt(kn)
        var p0 = rkn
        var q0 = IntMax(1)
        var q1 = kn &- p0*p0
        var b0, b1, p1, q2 : IntMax
        for i in 0..<IntMax.sqrt(2 * rkn) {
            // print("Stage 1: p0=\(p0), q0=\(q0), q1=\(q1)")
            b1 = (rkn &+ p0) / q1
            p1 = b1 &* q1 &- p0
            q2 = q0 &+ b1 &* (p0 - p1)
            if i & 1 == 1 {
                let rq = IntMax.sqrt(q1)
                if rq * rq == q1 {
                    //  square root found; the algorithm cannot fail now.
                    b0 = (rkn &- p0) / rq
                    p0 = b0 &* rq &+ p0
                    q0 = rq
                    q1 = (kn &- p0*p0) / q0
                    while true {
                        // print("Stage 2: p0=\(p0), q0=\(q0), q1=\(q1)")
                        b1 = (rkn &+ p0) / q1
                        p1 = b1 &* q1 &- p0
                        q2 = q0 &+ b1 &* (p0 - p1)
                        if p0 == p1 {
                            return UIntMax.gcd(n, UIntMax(p1))
                        }
                        p0 = p1; q0 = q1; q1 = q2;
                    }
                }
            }
            p0 = p1; q0 = q1; q1 = q2
        }
        return 1
    }
}
public extension BigUInt {
    public static func squfof_one(n:BigUInt, _ k:BigUInt)->BigUInt {
        // print("n=\(n),k=\(k)")
        if n < 2      { return 1 }
        if n & 1 == 0 { return 2 }
        let rn = BigUInt.sqrt(n)
        if rn * rn == n { return rn }
        let kn = k.asBigInt! * n.asBigInt!
        let rkn = BigInt.sqrt(kn)
        var p0 = rkn
        var q0 = BigInt(1)
        var q1 = kn - p0*p0
        var b0, b1, p1, q2 : BigInt
        for i in 0..<(BigInt.sqrt(2 * rkn)) {
            // print("Stage 1: p0=\(p0), q0=\(q0), q1=\(q1)")
            b1 = (rkn + p0) / q1
            p1 = b1 * q1 - p0
            q2 = q0 + b1 * (p0 - p1)
            if i & 1 == 1 {
                let rq = BigInt.sqrt(q1)
                if rq * rq == q1 {
                    //  square root found; the algorithm cannot fail now.
                    b0 = (rkn - p0) / rq
                    p0 = b0 * rq + p0
                    q0 = rq
                    q1 = (kn - p0*p0) / q0
                    while true {
                        // print("Stage 2: p0=\(p0), q0=\(q0), q1=\(q1)")
                        b1 = (rkn + p0) / q1
                        p1 = b1 * q1 - p0
                        q2 = q0 + b1 * (p0 - p1)
                        if p0 == p1 {
                            return BigUInt.gcd(n.asBigUInt!, p1.asUnsigned!)
                        }
                        p0 = p1; q0 = q1; q1 = q2;
                    }
                }
            }
            p0 = p1; q0 = q1; q1 = q2
        }
        return 1
    }
}
public extension POUInt {
    /// Try to factor `n` by [SQUFOF] = Shanks' Square Forms Factorization
    ///
    /// [SQUFOF]: http://en.wikipedia.org/wiki/Shanks'_square_forms_factorization
    public static func squfof(n:Self, verbose:Bool = false)->Self {
        // if verbose { print("ks=\(ks)") }
        let threshold = IntMax.max.asUnsigned!.asBigUInt!
        for k in POUtil.Prime.squfofMultipliers {
            let bn = n.asBigUInt!
            let bk = k.asBigUInt!
            var g:Self = 0
            if threshold < bn * bk {
                g = Self(BigUInt.squfof_one(bn, bk))
                if verbose { print("BigUInt.squof(\(n),\(k)) == \(g)") }
            } else {
                g = Self(UIntMax.squfof_one(n.toUIntMax(), k.toUIntMax()))
                if verbose {  print("UIntMax.squof(\(n),\(k)) == \(g)") }
            }
            if g != 1 { return g }
        }
        return 1
    }
    /// Try to factor `n` by [Pollard's rho] algorithm
    ///
    /// [Pollard's rho]: https://en.wikipedia.org/wiki/Pollard%27s_rho_algorithm
    ///
    /// - parameter n: the number to factor
    /// - parameter l: the number of iterations
    /// - parameter c: seed
    public static func pollardsRho(n:Self, _ l:Self, _ c:Self, verbose:Bool=false)->Self {
        var (x, y, j) = (Self(2), Self(2), Self(2))
        for i in 1...l {
            x = mulmod(x, x, mod:n)
            x += c
            let d = Self.gcd(x < y ? y - x : x - y, n);
            if (d != 1) {
                if verbose { print("pollardsRho(\(n), \(l), \(c)): i=\(i), d=\(d)") }
                return d == n ? 1 : d
            }
            if (i % j == 0) {
                y = x
                j += j
            }
        }
        if verbose { print("pollardsRho(\(n), \(l), \(c)): giving up") }
        return 1
    }
    /// factor `n` and return prime factors of it in array.
    ///
    /// axiom: `self.primeFactors.reduce(1,combine:*) == self` for any `self`
    ///
    /// It should succeed for all `u <= UInt.max` but may fail for larger numbers.
    /// In which case `1` is prepended to the result so the axiom still holds.
    ///
    /// If `verbose` is `true`, it shows the diagnostics
    ///
    public static func factor(n:Self, verbose v:Bool=false)->[Self] {
        var k = n
        if k < 2 { return [k] }
        if k.isPrime { return [k] }
        var result = [Self]()
        for p in POUtil.Prime.tinyPrimes.map({Self($0)}) {
            while k % p == 0 { result.append(p); k /= p }
            if k == 1 { return result }
        }
        if k.isPrime { return result + [k] }
        var d = Self.pollardsRho(k, 2048, 3, verbose:v)
        if d == 1 {
            d = Self.squfof(n, verbose:v)
        }
        result += d != 1 ? factor(d, verbose:v) + factor(k/d, verbose:v) : [1, k]
        result.sortInPlace(<)
        return result
    }
    /// factor `self` and return prime factors of it in array.
    ///
    /// axiom: `self.primeFactors.reduce(1,combine:*) == self` for any `self`
    ///
    /// It should succeed for all `u <= UInt.max` but may fail for larger numbers.
    /// In which case `1` is prepended to the result so the axiom still holds.
    public var primeFactors:[Self] {
        return Self.factor(self)
    }
}
public extension POInt {
    public var isPrime:Bool {
        return self < 2 ? false : self.abs.asUnsigned!.isPrime
    }
    // appears to be the same as POUInt version but addWithOveerflow is internally different
    public var nextPrime:Self? {
        if self < 2 { return 2 }
        var (u, o):(Self, Bool)
        (u, o) = Self.addWithOverflow(self, self & 1 == 0 ? 1 : 2)
        if o { return nil }
        while !u.isPrime {
            (u, o) = Self.addWithOverflow(u, 2)
            if o { return nil }
        }
        return u
    }
    public var prevPrime:Self? {
        return self <= 2 ? nil : Self(self.abs.asUnsigned!.prevPrime!)
    }
    /// the prime factors of `self`
    ///
    /// axiom: `u.primeFactors.reduce(1,*) == u` for any `u:UInt`
    ///
    /// It may fail for `u > Int.max`.
    /// In which case `1` is prepended to the result.
    /// For negative `self`, `-1` is prepended
    public var primeFactors:[Self] {
        let factors = self.abs.asUnsigned!.primeFactors.map{ Self($0) }
        return self.isSignMinus ? [-1] + factors : factors
    }
}
public extension BigUInt {
    public static let A014233_1x:[BigUInt] = [
        "318665857834031151167461",
        "3317044064679887385961981"
    ]
    public var isSurelyPrime:(Bool, surely:Bool) {   // a little more stringent tests
        if self < 2      { return (false, true) }
        if let self64 = self.asUInt64 { return (self64.isPrime, true) }
        if BigUInt.A014233_1x.last! <= self {
            let isPrime = self.isPrime
            return (isPrime, !isPrime)
        }
        if self & 1 == 0 { return (self == 2, true) }
        if self % 3 == 0 { return (self == 3, true) }
        if self % 5 == 0 { return (self == 5, true) }
        if self % 7 == 0 { return (self == 7, true) }
        if let mp = self.isMersennePrime { return (mp, true) }
        typealias PP = POUtil.Prime
        for i in 0..<PP.A014233.count {
            // print("\(__FILE__):\(__LINE__): \(self).millerRabinTest(\(PP.tinyPrimes[i]))")
            if self.millerRabinTest(PP.tinyPrimes[i]) == false { return (false, true) }
            if self < BigUInt(PP.A014233[i]) { return (true, true) }
        }
        // cf. http://arxiv.org/abs/1509.00864
        for i in 0..<BigUInt.A014233_1x.count {
            let j = i + 11
            // print("\(__FILE__):\(__LINE__): \(self).millerRabinTest(\(PP.tinyPrimes[j]))")
            if self.millerRabinTest(PP.tinyPrimes[j]) == false { return (false, true) }
            if self < BigUInt.A014233_1x.last! { return (true, true) }
        }
        // should not reach here
        let isPrime = self.isLucasProbablePrime
        return (isPrime, !isPrime)
    }
}
