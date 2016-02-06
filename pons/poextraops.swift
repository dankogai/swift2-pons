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

infix operator **   { associativity right precedence 160 }    // Exponentiative, same as << and >>
infix operator **=  { associativity right precedence  90 }    // Assignment, same as <<= and >>=

public func **<L:PONumber, R:POInteger>(lhs:L, rhs:R)->L {
    return R.pow(lhs, rhs)
}
public func **=<L:PONumber, R:POInteger>(inout lhs:L, rhs:R) {
    lhs = lhs ** rhs
}
