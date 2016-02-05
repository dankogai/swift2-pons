//
//  poextraops.swift
//  pons
//
//  Created by Dan Kogai on 2/4/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

// To be consistent with bitwise xor

infix operator ^^   { associativity left precedence 120 }   // Conjunctive, same as &&
infix operator ^^=  { associativity right precedence 90 }   // Assignment, same as &&=

public func ^^(lhs:Bool, rhs:Bool)->Bool {
    return Bool.xor(lhs, rhs)
}
public func ^^=(inout lhs:Bool, rhs:Bool) {
    lhs = lhs ^^ rhs
}

//public extension POInteger {
//    /// lhs to the rhs
//    public static func pow(lhs: Self, _ rhs:Self)->Self {
//        guard 0 <= lhs else {
//            fatalError("negative exponent not supported")
//        }
//        if lhs == Self(0) { return Self(1) }
//        if rhs == Self(1) { return lhs }
//        // cf. https://en.wikipedia.org/wiki/Exponentiation_by_squaring
//        var result = Self(1)
//        var t = lhs, n = rhs
//        while n > Self(0) {
//            if n & 1 == 1 {
//                result *= t
//            }
//            n >>= Self(1); t = Self.multiplyWithOverflow(t, t).0
//        }
//        return result
//    }
//}

infix operator **   { associativity right precedence 160 }    // Exponentiative, same as << and >>
infix operator **=  { associativity right precedence  90 }    // Assignment, same as <<= and >>=

public func **<L:PONumber, R:POInteger>(lhs:L, rhs:R)->L {
    return R.pow(lhs, rhs)
}
public func **=<L:PONumber, R:POInteger>(inout lhs:L, rhs:R) {
    lhs = lhs ** rhs
}
