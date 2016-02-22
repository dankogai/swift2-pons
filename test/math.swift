//
//  math.swift
//  test
//
//  Created by Dan Kogai on 2/17/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

extension TAP {
    /// ok if `actual` is close enough to `expected`
    func like<R:POReal>(actual:R, _ expected:R, _ message:String = "")->Bool {
        if expected.isNaN {
            return self.ok(actual.isNaN, message)
        }
        if expected.isInfinite  {
            return self.ok(actual.isInfinite, message)
        }
        if actual == expected {
            return self.ok(actual == expected, message)
        }
        let epsilon = R(0x1p-52)
        let error = Swift.abs(actual - expected) / Swift.abs(actual + expected)
        print("#       got: \(actual)")
        print("#  expected: \(expected)")
        print("#     error: \(error):", error <= epsilon ? "ok" : "NOT OK")
        return self.ok(error <= epsilon, message)
    }
    func check<R:POReal>(q:R,
        _ fr:(R, precision:Int)->R, _ fd:(Double, precision:Int)->Double,
        name:String)->Bool {
        let vq = fr(q,precision:64)
        let vd = fd(q.toDouble(),precision:Double.precision)
        return self.like(vq.toDouble(), vd, "\(R.self).\(name)(\(q.toDouble())) => \(vq)")
    }
    func check<R:POReal>(l:R, _ r:R, _
        fr:(R, R, precision:Int)->R, _ fd:(Double, Double, precision:Int)->Double,
        name:String)->Bool {
        let vq = fr(l, r, precision:64)
        let vd = fd(l.toDouble(), r.toDouble(), precision:Double.precision)
        return self.like(vq.toDouble(), vd, "\(R.self).\(name)(\(l.toDouble()), \(r.toDouble())) => \(vq)")
    }
}
func testBigRat(test:TAP, _ v:BigRat) {
    test.check(v, BigRat.sqrt,  Double.sqrt,    name:"sqrt")
    test.check(v, BigRat.exp,   Double.exp,     name:"exp")
    test.check(v, BigRat.log,   Double.log,     name:"log")
    test.check(v, BigRat.log10, Double.log10,   name:"log10")
    test.check(v, BigRat.cos,   Double.cos,     name:"acos")
    test.check(v, BigRat.sin,   Double.sin,     name:"asin")
    test.check(v, BigRat.tan,   Double.tan,     name:"atan")
    test.check(v, BigRat.acos,  Double.acos,    name:"acos")
    test.check(v, BigRat.asin,  Double.asin,    name:"asin")
    test.check(v, BigRat.atan,  Double.atan,    name:"atan")
    test.check(v, BigRat.cosh,  Double.cosh,    name:"cosh")
    test.check(v, BigRat.sinh,  Double.sinh,    name:"sinh")
    test.check(v, BigRat.tanh,  Double.tanh,    name:"tanh")
    test.check(v, BigRat.acosh, Double.acosh,   name:"acosh")
    test.check(v, BigRat.asinh, Double.asinh,   name:"asinh")
    test.check(v, BigRat.atanh, Double.atanh,   name:"atanh")
}
func testBigFloat(test:TAP, _ v:BigFloat) {
    test.check(v, BigFloat.sqrt,    Double.sqrt,    name:"sqrt")
    test.check(v, BigFloat.exp,     Double.exp,     name:"exp")
    test.check(v, BigFloat.log,     Double.log,     name:"log")
    test.check(v, BigFloat.log10,   Double.log10,   name:"log10")
    test.check(v, BigFloat.cos,     Double.cos,     name:"acos")
    test.check(v, BigFloat.sin,     Double.sin,     name:"asin")
    test.check(v, BigFloat.tan,     Double.tan,     name:"atan")
    test.check(v, BigFloat.acos,    Double.acos,    name:"acos")
    test.check(v, BigFloat.asin,    Double.asin,    name:"asin")
    test.check(v, BigFloat.atan,    Double.atan,    name:"atan")
    test.check(v, BigFloat.cosh,    Double.cosh,    name:"cosh")
    test.check(v, BigFloat.sinh,    Double.sinh,    name:"sinh")
    test.check(v, BigFloat.tanh,    Double.tanh,    name:"tanh")
    test.check(v, BigFloat.acosh,   Double.acosh,   name:"acosh")
    test.check(v, BigFloat.asinh,   Double.asinh,   name:"asinh")
    test.check(v, BigFloat.atanh,   Double.atanh,   name:"atanh")
}
func testMath(test:TAP, num:Int=1, den:Int=4) {
    let DBL_MAX = 0x1.fffffffffffffp+1023
    // let DBL_MIN = 0x1p-1022
    //  -DBL_MIN, +DBL_MIN cannot be decently tested w/ the script above
    for d in [-Double.infinity, -DBL_MAX, -0.0, +0.0, +DBL_MAX, +Double.infinity] {
        let q = BigRat(d)
        // testBigRat(q)    // Takes too long for +-DBL_MAX.
        let r = BigFloat(q)
        testBigFloat(test, r)
    }
    //
    for i in 0...8 {
        for s in [-1.0, +1.0] {
            let q = BigRat(s * Double.pow(2, Double(i-4)))
            testBigRat(test, q)
            let f = BigFloat(q)
            testBigFloat(test, f)
        }
    }
    for y in [-1.0, -0.0, +0.0, +1.0] {
        for x in [-1.0, -0.0, +0.0, +1.0] {
            let qx = BigRat(x)
            let qy = BigRat(y)
            test.check(qy, qx, BigRat.atan2, Double.atan2, name:"atan2")
            let rx = BigFloat(x)
            let ry = BigFloat(y)
            test.check(ry, rx, BigFloat.atan2,  Double.atan2, name:"atan2")
        }
    }
}