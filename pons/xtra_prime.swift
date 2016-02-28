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
    /// primes less than 64
    public static let tinyPrimes:[Int] = {
        var ps = [2, 3]
        var n = 5
        while n < 64 {
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
public extension UIntMax {
    public var isPrime:Bool {
        if self < 2      { return false }
        if self & 1 == 0 { return self == 2 }
        if self % 3 == 0 { return self == 3 }
        if self % 5 == 0 { return self == 5 }
        if self % 7 == 0 { return self == 7 }
        if let mp = self.isMersennePrime { return mp }
        typealias PP = POUtil.Prime
        for i in 0..<PP.A014233.count {
            // print("\(__FILE__):\(__LINE__): \(self).millerRabinTest(\(PP.tinyPrimes[i]))")
            if self.millerRabinTest(PP.tinyPrimes[i]) == false { return false }
            if self < PP.A014233[i] { break }
        }
        return true
    }
}
public extension POUInt {
    //
    //  Primarity Test
    //
    /// [Miller-Rabin] test `n` for `base`
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
            y = Self.mulmod(y, y, self)
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
    public var isPrime:Bool {
        return Self.precision <= UIntMax.precision
            ? self.toUIntMax().isPrime
            : self.asBigUInt!.isSurelyPrime.0
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
}
public extension BigUInt {
    public static let A014233_1x:[BigUInt] = [
        "318665857834031151167461",
        "3317044064679887385961981"
    ]
    public var isSurelyPrime:(Bool, surely:Bool) {   // a little more stringent tests
        if self < 2      { return (false, true) }
        if let self64 = self.asUInt64 { return (self64.isPrime, true) }
        if self & 1 == 0 { return (self == 2, true) }
        if self % 3 == 0 { return (self == 3, true) }
        if self % 5 == 0 { return (self == 5, true) }
        if self % 7 == 0 { return (self == 7, true) }
        if let mp = self.isMersennePrime { return (mp, true) }
        typealias PP = POUtil.Prime
        for i in 0..<PP.A014233.count {
            // print("\(__FILE__):\(__LINE__): \(self).millerRabinTest(\(PP.tinyPrimes[i]))")
            if self.millerRabinTest(PP.tinyPrimes[i]) == false { return (false, true) }
            if self < BigUInt(PP.A014233[i]) { break }
        }
        // cf. http://arxiv.org/abs/1509.00864
        for i in 0..<BigUInt.A014233_1x.count {
            let j = i + 11
            // print("\(__FILE__):\(__LINE__): \(self).millerRabinTest(\(PP.tinyPrimes[j]))")
            if self.millerRabinTest(PP.tinyPrimes[j]) == false { return (false, true) }
        }
        // no longer surely prime beyond A014233_13
        return (self.millerRabinTest(43), self <= BigUInt.A014233_1x.last!)
    }
}
