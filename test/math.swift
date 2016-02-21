//
//  math.swift
//  test
//
//  Created by Dan Kogai on 2/17/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

// Approximation tests for resulting doubles
func approx(qd:Double, _ dd:Double)->Bool {
    if qd.isNaN {
        if dd.isNaN { return true }
        print("approx: qd = \(qd), dd=\(dd)")
        return false
    }
    if qd.isInfinite  {
        if dd.isInfinite && qd.isSignMinus == dd.isSignMinus { return true }
        print("approx: qd = \(qd), dd=\(dd)")
        return false
    }
    if qd.isZero  {
        if dd.isZero && qd.isSignMinus == dd.isSignMinus { return true }
        print("approx: qd = \(qd), dd=\(dd)")
        return false
    }
    if qd == dd { return true }
    let diff = Swift.abs(qd - dd) / Swift.abs(qd + dd)
    if diff > 0x2p-52 {
        print("approx: qd = \(qd), dd=\(dd), diff=\(diff) > \(0x2p-52)")
        return false
    }
    return true
}
// Approximation tests for unary functions
func approx<R:POReal>(q:R, _ fq:(R,precision:Int)->R, _ fd:(Double,precision:Int)->Double)->Bool {
    // print(fq(q,precision:64).toDouble() - fd(q.toDouble()))
    let qd = fq(q,precision:64).toDouble()
    let dd = fd(q.toDouble(),precision:Double.precision)
    return approx(qd, dd)
}
// Approximation tests for binary functions
func approx<R:POReal>(q:R, _ r:R, _ fq:(R,R,precision:Int)->R, _ fd:(Double,Double,precision:Int)->Double)->Bool {
    // print(fq(q,precision:64).toDouble() - fd(q.toDouble()))
    let qd = fq(q,r, precision:64).toDouble()
    let dd = fd(q.toDouble(),r.toDouble(), precision:Double.precision)
    return approx(qd, dd)
}
// math
func testBigRat(q:BigRat) {
    test.eq(approx(q, BigRat.acos,  Double.acos),   true,   "BigRat.acos(\(q.toDouble()))")
    test.eq(approx(q, BigRat.acosh, Double.acosh),  true,   "BigRat.acosh(\(q.toDouble()))")
    test.eq(approx(q, BigRat.asin,  Double.asin),   true,   "BigRat.asin(\(q.toDouble()))")
    test.eq(approx(q, BigRat.asinh, Double.asinh),  true,   "BigRat.asinh(\(q.toDouble()))")
    test.eq(approx(q, BigRat.atan,  Double.atan),   true,   "BigRat.atan(\(q.toDouble()))")
    test.eq(approx(q, BigRat.atanh, Double.atanh),  true,   "BigRat.atanh(\(q.toDouble()))")
    test.eq(approx(q, BigRat.cos,   Double.cos),    true,   "BigRat.cos(\(q.toDouble()))")
    test.eq(approx(q, BigRat.cosh,  Double.cosh),   true,   "BigRat.cosh(\(q.toDouble()))")
    test.eq(approx(q, BigRat.exp,   Double.exp),    true,   "BigRat.exp(\(q.toDouble()))")
    test.eq(approx(q, BigRat.log,   Double.log),    true,   "BigRat.log(\(q.toDouble()))")
    test.eq(approx(q, BigRat.sin,   Double.sin),    true,   "BigRat.sin(\(q.toDouble()))")
    test.eq(approx(q, BigRat.sinh,  Double.sinh),   true,   "BigRat.sinh(\(q.toDouble()))")
    test.eq(approx(q, BigRat.sqrt,  Double.sqrt),   true,   "BigRat.sqrt(\(q.toDouble()))")
    test.eq(approx(q, BigRat.tan,   Double.tan),    true,   "BigRat.tan(\(q.toDouble()))")
    test.eq(approx(q, BigRat.tanh,  Double.tanh),   true,   "BigRat.tanh(\(q.toDouble()))")
}
func testBigFloat(f:BigFloat) {
    test.eq(approx(f, BigFloat.acos,    Double.acos),   true,   "BigFloat.acos(\(f.toDouble()))")
    test.eq(approx(f, BigFloat.acosh,   Double.acosh),  true,   "BigFloat.acosh(\(f.toDouble()))")
    test.eq(approx(f, BigFloat.asin,    Double.asin),   true,   "BigFloat.asin(\(f.toDouble()))")
    test.eq(approx(f, BigFloat.asinh,   Double.asinh),  true,   "BigFloat.asinh(\(f.toDouble()))")
    test.eq(approx(f, BigFloat.atan,    Double.atan),   true,   "BigFloat.atan(\(f.toDouble()))")
    test.eq(approx(f, BigFloat.atanh,   Double.atanh),  true,   "BigFloat.atanh(\(f.toDouble()))")
    test.eq(approx(f, BigFloat.cos,     Double.cos),    true,   "BigFloat.cos(\(f.toDouble()))")
    test.eq(approx(f, BigFloat.cosh,    Double.cosh),   true,   "BigFloat.cosh(\(f.toDouble()))")
    test.eq(approx(f, BigFloat.exp,     Double.exp),    true,   "BigFloat.exp(\(f.toDouble()))")
    test.eq(approx(f, BigFloat.log,     Double.log),    true,   "BigFloat.log(\(f.toDouble()))")
    test.eq(approx(f, BigFloat.sin,     Double.sin),    true,   "BigFloat.sin(\(f.toDouble()))")
    test.eq(approx(f, BigFloat.sinh,    Double.sinh),   true,   "BigFloat.sinh(\(f.toDouble()))")
    test.eq(approx(f, BigFloat.sqrt,    Double.sqrt),   true,   "BigFloat.sqrt(\(f.toDouble()))")
    test.eq(approx(f, BigFloat.tan,     Double.tan),    true,   "BigFloat.tan(\(f.toDouble()))")
    test.eq(approx(f, BigFloat.tanh,    Double.tanh),   true,   "BigFloat.tanh(\(f.toDouble()))")
}
func testMath(test:TAP, num:Int=1, den:Int=4) {
    //  -DBL_MIN, +DBL_MIN cannot be decently tested w/ the script above
    for d in [-Double.infinity, -DBL_MAX, -0.0, +0.0, +DBL_MAX, +Double.infinity] {
        let q = BigRat(d)
        // testBigRat(q)    // Takes too long for +-DBL_MAX.
        let r = BigFloat(q)
        testBigFloat(r)
    }
    //
    for i in 0...8 {
        for s in [-1.0, +1.0] {
            let q = BigRat(s * Double.pow(2, Double(i-4)))
            testBigRat(q)
            let f = BigFloat(q)
            testBigFloat(f)
        }
    }
    for y in [-1.0, -0.0, +0.0, +1.0] {
        for x in [-1.0, -0.0, +0.0, +1.0] {
            let qx = BigRat(x)
            let qy = BigRat(y)
            test.eq(approx(qy, qx, BigRat.atan2,    Double.atan2), true, "BigRat.atan2(\(y), \(x))")
            let rx = BigFloat(x)
            let ry = BigFloat(y)
            test.eq(approx(ry, rx, BigFloat.atan2,  Double.atan2), true,  "BigFloat.atan2(\(y), \(x))")
        }
    }
}