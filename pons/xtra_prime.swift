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
        public func generate()->AnyGenerator<UIntMax> {
            var currPrime:UIntMax = 0
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
    public static let tinyPrimes:[UIntMax] = {
        var ps:[UIntMax] = [2, 3]
        var n:UIntMax = 5
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
public extension POUInt {
    /// [Miller-Rabin] test `n` for `base`
    ///
    /// [Miller-Rabin]: https://en.wikipedia.org/wiki/Miller%E2%80%93Rabin_primality_test
//    public static func powmod(var _ base:Self, var _ power:Self, mod:Self) -> Self {
//        var result:Self = 1
//        while power > 0 {
//            if power & 1 == 1 { result = (result * base) % mod }
//            base = (base * base) % mod
//            power >>= 1;
//        }
//        return result
//    }
    public func millerRabinTest(base:UIntMax)->Bool {
        if self < 2      { return false }
        if self & 1 == 0 { return self == 2 }
        var d = self - 1
        while d & 1 == 0 { d >>= 1 }
        var t = d
        var y = Self.pow(Self(base), t, mod:self)
        // print("\(__FILE__):\(__LINE__): base=\(base),\nself=\(self),\ny=\(y)\nt=\(t)")
        while t != self-1 && y != 1 && y != self-1 {
            y = (y * y) % self
            t <<= 1
        }
        // print("\(__FILE__):\(__LINE__): base=\(base),self=\(self),y=\(y),t=\(t)")

        return y == self-1 || t & 1 == 1
    }
    public var isPrime:Bool {
        if self < 2      { return false }
        if self & 1 == 0 { return self == 2 }
        if self % 3 == 0 { return self == 3 }
        if self % 5 == 0 { return self == 5 }
        if self % 7 == 0 { return self == 7 }
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
    public var isPrime:Bool { return self.asUnsigned.isPrime }
    public var nextPrime:Self { return Self(self.asUnsigned.nextPrime) }
    public var prevPrime:Self { return Self(self.asUnsigned.prevPrime) }
}
