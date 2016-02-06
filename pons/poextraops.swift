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

public func **<R:POInt>(lhs:R, rhs:R)->R {
    return R.pow(lhs, rhs)
}
public func **=<R:POInt>(inout lhs:R, rhs:R) {
    lhs = lhs ** rhs
}
public func **<L:POReal, R:POInt>(lhs:L, rhs:R)->L {
    return L(Double.pow(lhs.toDouble(), rhs.asDouble))
}
public func **=<L:POReal, R:POInt>(inout lhs:L, rhs:R) {
    lhs = lhs ** rhs
}
public func **<R:POReal>(lhs:R, rhs:R)->R {
    return R.pow(lhs, rhs)
}
public func **=<R:POReal>(inout lhs:R, rhs:R) {
    lhs = lhs ** rhs
}
public func **<C:POComplexReal>(lhs:C, rhs:C)->C {
    return C.pow(lhs, rhs)
}
public func **=<C:POComplexReal>(inout lhs:C, rhs:C) {
    lhs = lhs ** rhs
}
public func **<C:POComplexReal>(lhs:C, rhs:C.RealType)->C {
    return C.pow(lhs, rhs)
}
public func **=<C:POComplexReal>(inout lhs:C, rhs:C.RealType) {
    lhs = lhs ** rhs
}
