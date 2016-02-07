//
//  porational.swift
//  pons
//
//  Created by Dan Kogai on 2/7/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

public protocol PORational: POReal {
    typealias UIntType:POUInt
    var numer:UIntType { get set }
    var denom:UIntType { get set }
    init(_:UIntType, _:UIntType, isSignMinus:Bool, normalized:Bool)
}

public extension POInteger {
    public static func gcd(lhs: Self, _ rhs:Self)->Self {
        var (r, q) = lhs < rhs ? (lhs, rhs) : (rhs, lhs)
        if r == 0 { fatalError("To divide by zero, call Chuck Norris") }
        while r > 0 {
            q %= r
            (q, r) = (r, q)
        }
        return q
    }
}

public extension PORational {
    public init(_ n:Int) {
        self.init(UIntType(n), UIntType(1), isSignMinus:n.isSignMinus, normalized:true)
    }
    public init(_ n:Int, _ d:Int) {
        self.init(UIntType(n.abs), UIntType(d.abs),
            isSignMinus:Bool.xor(n.isSignMinus, d.isSignMinus),
            normalized:false
        )
    }
    public var description:String {
        let sign = self.isSignMinus ? "-" : ""
        return "(\(sign)\(numer)/\(denom))"
    }
}


public struct Rational<U:POUInt> : CustomStringConvertible {
    public typealias UIntType = U
    public var numer:U = 0
    public var denom:U = 1
    public var isSignMinus:Bool = false
    public init(_ n:U, _ d:U, isSignMinus:Bool=false, normalized:Bool=false) {
        numer = n
        denom = d
        self.isSignMinus = isSignMinus
    }
    public var description:String {
        let sign = self.isSignMinus ? "-" : ""
        return "(\(sign)\(numer)/\(denom))"
    }

}

public extension POInt {
    public var asRational:Rational<Self.UIntType> {
        return Rational(self.abs.asUnsigned, 1, isSignMinus:self.isSignMinus, normalized:true)
    }
}