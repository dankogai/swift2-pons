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
        public func generate()->AnyGenerator<BigUInt> {
            var currPrime = BigUInt(0)
            return anyGenerator {
                let nextPrime = currPrime.nextPrime
                if nextPrime > currPrime {
                    currPrime = nextPrime;
                    return currPrime
                }
                return nil
            }
        }
    }
}
public extension POUtil.Prime {
    /// primes less than 2048
    public static let tinyPrimes:[Int] = {
        var ps = [2, 3]
        var n = 5
        while n < 2048 {
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
    public static let A014233 = [
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
public extension POUInt {
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
        let p = Self(self.msbAt + 1) // mersenne number = number of bits
        // print("\(__FILE__):\(__LINE__): p = \(p), self = \(self)")
        guard self == Self(1)<<p - 1 else {
            return nil  // self is not 2**n - 1
        }
        guard p.isPrime else {  // if n is composite, so is Mn
            return false
        }
        var s:Self = 4
        for _ in 0..<(p-2) {
            s = (s * s - 2) % self
        }
        return s == 0
    }
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
            if self < Self(PP.A014233[i]) { break }
        }
        return true
    }
    public var nextPrime:Self {
        if self < 2 { return 2 }
        var u = self + (self & 1 == 0 ? 1 : 2)
        while !u.isPrime { u = u + 2 }
        return u
    }
    public var prevPrime:Self {
        if self < 2 { return 2 }
        var u = self - (self & 1 == 0 ? 1 : 2)
        while !u.isPrime { u = u - 2 }
        return u
    }
}
public extension POInt {
    public var isPrime:Bool { return self.toUIntMax().isPrime }
    public var nextPrime:Self { return Self(self.toUIntMax().nextPrime) }
    public var prevPrime:Self { return Self(self.toUIntMax().prevPrime) }
}
public extension BigInt {
    public var isPrime:Bool { return self.asUnsigned!.isPrime }
    public var nextPrime:BigInt { return self.asUnsigned!.nextPrime.asSigned! }
    public var prevPrime:BigInt { return self.asUnsigned!.prevPrime.asSigned! }
}
public extension BigUInt {
    public static let A014233_12 = BigUInt("318665857834031151167461")
    public var isSurelyPrime:(Bool, surely:Bool) {   // a little more stringent tests
        if self < 2      { return (false, true) }
        if self & 1 == 0 { return (self == 2, true) }
        if let _ = self.asUInt32 { // small guys are handled by small types
            // print("\(__FILE__):\(__LINE__): self = \(u32) > UInt32.max")
            return (self.asUInt64!.isPrime, true)   // that way it never overlows
        }
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
        if self.millerRabinTest(37) == false { return (false, true) }   // one more thing for sure!
        return (self.millerRabinTest(41), false)                        // no longer surely prime
    }
    public var isPrime:Bool {
        return self.isSurelyPrime.0
    }
}
