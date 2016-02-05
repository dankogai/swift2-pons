//
//  poextraops.swift
//  pons
//
//  Created by Dan Kogai on 2/4/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

public extension POInteger {
    /// lhs to the rhs
    public static func pow(lhs: Self, _ rhs:Self)->Self {
        guard 0 <= lhs else {
            fatalError("negative exponent not supported")
        }
        if lhs == Self(0) { return Self(1) }
        if rhs == Self(1) { return lhs }
        // cf. https://en.wikipedia.org/wiki/Exponentiation_by_squaring
        var result = Self(1)
        var t = lhs, n = rhs
        while n > Self(0) {
            if n & 1 == 1 {
                result *= t
            }
            n >>= Self(1); t = Self.multiplyWithOverflow(t, t).0
        }
        return result
    }
}

infix operator ** { associativity right precedence 170 }
infix operator **= { associativity right precedence 90 }

public func **<T:POInteger>(lhs:T, rhs:T)->T {
    return T.pow(lhs, rhs)
}
public func **=<T:POInteger>(inout lhs:T, rhs:T) {
    lhs = lhs ** rhs
}
