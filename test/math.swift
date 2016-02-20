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
func testMath(test:TAP, num:Int=1, den:Int=4) {
    for i in 0...(num*den) {
        for s in [-1.0, 1.0] {
            let q = BigInt(s*Double(i)).over(BigInt(den))
            test.eq(approx(q, BigRat.acos,  Double.acos),   true,   "BigRat.acos(\(q))")
            test.eq(approx(q, BigRat.acosh, Double.acosh),  true,   "BigRat.acosh(\(q))")
            test.eq(approx(q, BigRat.asin,  Double.asin),   true,   "BigRat.asin(\(q))")
            test.eq(approx(q, BigRat.asinh, Double.asinh),  true,   "BigRat.asinh(\(q))")
            test.eq(approx(q, BigRat.atan,  Double.atan),   true,   "BigRat.atan(\(q))")
            test.eq(approx(q, BigRat.atanh, Double.atanh),  true,   "BigRat.atanh(\(q))")
            test.eq(approx(q, BigRat.cos,   Double.cos),    true,   "BigRat.cos(\(q))")
            test.eq(approx(q, BigRat.cosh,  Double.cosh),   true,   "BigRat.cosh(\(q))")
            test.eq(approx(q, BigRat.exp,   Double.exp),    true,   "BigRat.exp(\(q))")
            test.eq(approx(q, BigRat.log,   Double.log),    true,   "BigRat.log(\(q))")
            test.eq(approx(q, BigRat.sin,   Double.sin),    true,   "BigRat.sin(\(q))")
            test.eq(approx(q, BigRat.sinh,  Double.sinh),   true,   "BigRat.sinh(\(q))")
            test.eq(approx(q, BigRat.sqrt,  Double.sqrt),   true,   "BigRat.sqrt(\(q))")
            test.eq(approx(q, BigRat.tan,   Double.tan),    true,   "BigRat.tan(\(q))")
            test.eq(approx(q, BigRat.tanh,  Double.tanh),   true,   "BigRat.tanh(\(q))")
            let f = BigFloat(q)
            test.eq(approx(f, BigFloat.acos,    Double.acos),   true,   "BigFloat.acos(\(f))")
            test.eq(approx(f, BigFloat.acosh,   Double.acosh),  true,   "BigFloat.acosh(\(f))")
            test.eq(approx(f, BigFloat.asin,    Double.asin),   true,   "BigFloat.asin(\(f))")
            test.eq(approx(f, BigFloat.asinh,   Double.asinh),  true,   "BigFloat.asinh(\(f))")
            test.eq(approx(f, BigFloat.atan,    Double.atan),   true,   "BigFloat.atan(\(f))")
            test.eq(approx(f, BigFloat.atanh,   Double.atanh),  true,   "BigFloat.atanh(\(f))")
            test.eq(approx(f, BigFloat.cos,     Double.cos),    true,   "BigFloat.cos(\(f))")
            test.eq(approx(f, BigFloat.cosh,    Double.cosh),   true,   "BigFloat.cosh(\(f))")
            test.eq(approx(f, BigFloat.exp,     Double.exp),    true,   "BigFloat.exp(\(f))")
            test.eq(approx(f, BigFloat.log,     Double.log),    true,   "BigFloat.log(\(f))")
            test.eq(approx(f, BigFloat.sin,     Double.sin),    true,   "BigFloat.sin(\(f))")
            test.eq(approx(f, BigFloat.sinh,    Double.sinh),   true,   "BigFloat.sinh(\(f))")
            test.eq(approx(f, BigFloat.sqrt,    Double.sqrt),   true,   "BigFloat.sqrt(\(f))")
            test.eq(approx(f, BigFloat.tan,     Double.tan),    true,   "BigFloat.tan(\(f))")
            test.eq(approx(f, BigFloat.tanh,    Double.tanh),   true,   "BigFloat.tanh(\(f))")
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