//
//  math.swift
//  test
//
//  Created by Dan Kogai on 2/17/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

let DBL_MAX = 0x1.fffffffffffffp+1023
let DBL_MIN = 0x1p-1022

extension TAP {
    /// ok if `actual` is close enough to `expected`
    func like(actual:Double, _ expected:Double, _ message:String = "")->Bool {
        if expected.isNaN {
            return self.ok(actual.isNaN, message)
        }
        if expected.isInfinite  {
            return self.ok(actual.isInfinite, message)
        }
        if actual == expected {
            return self.ok(actual == expected, message)
        }
        let epsilon = 0x1p-52
        let error = Swift.abs(actual - expected) / Swift.abs(actual + expected)
        print("#       got: \(actual.debugDescription)")
        print("#  expected: \(expected.debugDescription)")
        print("#     error: \(error.debugDescription):", actual.isSubnormal || error <= epsilon ? "ok" : "NOT OK")
        return self.ok(actual.isSubnormal || error <= epsilon, message)
    }
    func check<R:POReal>(r:R,
        _ fr:(R, precision:Int)->R, _ fd:(Double, precision:Int)->Double,
        name:String)->Bool {
        let vr = fr(r,precision:64)
        let vd = fd(r.toDouble(),precision:Double.precision)
        return self.like(vr.toDouble(), vd, "\(R.self).\(name)(\(r.toDouble())) => \(vr.debugDescription)")
    }
    func check<R:POReal>(l:R, _ r:R, _
        fr:(R, R, precision:Int)->R, _ fd:(Double, Double, precision:Int)->Double,
        name:String)->Bool {
        let vq = fr(l, r, precision:64)
        let vd = fd(l.toDouble(), r.toDouble(), precision:Double.precision)
        return self.like(vq.toDouble(), vd, "\(R.self).\(name)(\(l.toDouble()), \(r.toDouble())) => \(vq.debugDescription)")
    }
}
func testBigRat(test:TAP, _ v:BigRat) {
    test.check(v, BigRat.sqrt,  Double.sqrt,    name:"sqrt")
    test.check(v, BigRat.exp,   Double.exp,     name:"exp")
    test.check(v, BigRat.log,   Double.log,     name:"log")
    test.check(v, BigRat.log10, Double.log10,   name:"log10")
    test.check(v, BigRat.cos,   Double.cos,     name:"cos")
    test.check(v, BigRat.cos,   Double.cos,     name:"cos")
    test.check(v, BigRat.sin,   Double.sin,     name:"sin")
    test.check(v, BigRat.tan,   Double.tan,     name:"tan")
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
    test.check(v, BigFloat.cos,     Double.cos,     name:"cos")
    test.check(v, BigFloat.sin,     Double.sin,     name:"sin")
    test.check(v, BigFloat.tan,     Double.tan,     name:"tan")
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
func testMath(test:TAP, num:Int=8, den:Int=4) {
    // -DBL_MIN, +DBL_MIN cannot be reliably tested w/ the script above
    for d in [-Double.infinity, -DBL_MAX, -DBL_MIN, +DBL_MIN, -0.0, +0.0, +DBL_MAX, +Double.infinity] {
        let q = BigRat(d)
        if d.abs != DBL_MAX && d.abs != DBL_MIN {
            testBigRat(test, q) // Takes too long for +-DBL_MAX and +-DLB_MIN.
        }
        let r = BigFloat(q)
        testBigFloat(test, r)
    }
    for i in 0...num {
        for s in [-1.0, +1.0] {
            let q = BigRat(s * Double.pow(2, Double(i-den)))
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