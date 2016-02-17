//
//  pobigfloat.swift
//  test
//
//  Created by Dan Kogai on 2/17/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

public struct BigFloat {
    public var significand:BigInt = 0
    public var exponent:Int = 0
    public init(significand:BigInt, exponent:Int) {
        self.significand = significand
        self.exponent = exponent
    }
    public init(_ bi:BigInt) {
        significand = bi
        exponent = bi.msbAt
    }
    public init(_ bf:BigFloat) {
        significand = bf.significand
        exponent = bf.exponent
    }
    public init(_ i:Int) {
        self.init(i.asBigInt!)
    }
    public init(_ d:Double) {
        if d.isZero {
            exponent = 0
            significand = BigInt(d)
        } else {
            let (m, e) = Double.frexp(d)
            if Swift.abs(m) == 0.5 {
                significand = m < 0 ? -1 : 1
                exponent = e - 1
            } else {
                var s = Int(Double.ldexp(d, Double.precision))
                // print("d=\(d), m=\(m), e=\(e), s=\(s)")
                exponent = e - s.abs.msbAt - 1
                while s != 0 && s & 1 == 0 {
                    s >>= 1
                    exponent += 1
                }
                significand = s.asBigInt!
            }
        }
    }
    public var isSignMinus:Bool {
        return significand.isSignMinus
    }
    public func toDouble()->Double {
        return Double.ldexp(significand.toDouble(), exponent)
    }
}

