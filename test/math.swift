//
//  math.swift
//  test
//
//  Created by Dan Kogai on 2/17/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

// Approximation tests for unary functions
func approx<R:POReal>(q:R, _ fq:(R,precision:Int)->R, _ fd:(Double,precision:Int)->Double)->Bool {
    // print(fq(q,precision:64).toDouble() - fd(q.toDouble()))
    let qd = fq(q,precision:64).toDouble()
    let dd = fd(q.toDouble(),precision:Double.precision)
    if qd == dd { return true }
    let diff = Swift.abs(qd - dd) / Swift.abs(qd + dd)
    if diff > 0x2p-52 {
        print("qd = \(qd), dd=\(dd), diff=\(diff)")
        return false
    }
    return true
}
// Approximation tests for binary functions
func approx<R:POReal>(q:R, _ r:R, _ fq:(R,R,precision:Int)->R, _ fd:(Double,Double,precision:Int)->Double)->Bool {
    // print(fq(q,precision:64).toDouble() - fd(q.toDouble()))
    let qd = fq(q,r, precision:64).toDouble()
    let dd = fd(q.toDouble(),r.toDouble(), precision:Double.precision)
    if qd == dd { return true }
    let diff = Swift.abs(qd - dd) / Swift.abs(qd + dd)
    if diff > 0x2p-52 {
        print("qd = \(qd), dd=\(dd), diff=\(diff)")
        return false
    }
    return true
}
// math
func testMath(test:TAP, num:Int=1, den:Int=4) {
    test.eq(Rational.sqrt(-BigInt(1).over(1)).isNaN, true,  "sqrt(-1/1) is NaN")
    test.eq(Rational.log(-BigInt(1).over(1)).isNaN, true,   "log(-1/1) is NaN")
    test.eq(Rational.log(+BigInt(0).over(1)), -BigRat.infinity,   "log(0/1) is -inf")
    for i in 0...num {    // make 16 to make test more rigorous (but slow)
        let q = +BigInt(i).over(BigInt(den))
        let r = +BigFloat(i).divide(BigFloat(den))
        test.eq(approx(+q, BigRat.sqrt,     Double.sqrt), true,  "Rational vs Double: sqrt(\(+q))")
        test.eq(approx(+r, BigFloat.sqrt,   Double.sqrt), true,  "BigFloat vs Double: sqrt(\(+r))")
        test.eq(approx(+q, BigRat.log,      Double.log), true,  "Rational vs Double: log(\(+q))")
        test.eq(approx(+r, BigFloat.log,    Double.log), true,  "BigFloat vs Double: log(\(+r))")
        test.eq(approx(+q, BigRat.exp,      Double.exp), true,  "Rational vs Double: exp(\(+q))")
        test.eq(approx(+r, BigFloat.exp,    Double.exp), true,  "BigFloat vs Double: exp(\(+r))")
        test.eq(approx(+q, BigRat.cos,      Double.cos), true,  "Rational vs Double: cos(\(+q))")
        test.eq(approx(+r, BigFloat.cos,    Double.cos), true,  "BigFloat vs Double: cos(\(+r))")
        test.eq(approx(+q, BigRat.sin,      Double.sin), true,  "Rational vs Double: sin(\(+q))")
        test.eq(approx(+r, BigFloat.sin,    Double.sin), true,  "BigFloat vs Double: sin(\(+r))")
        test.eq(approx(+q, BigRat.tan,      Double.tan), true,  "Rational vs Double: tan(\(+q))")
        test.eq(approx(+r, BigFloat.tan,    Double.tan), true,  "BigFloat vs Double: tan(\(+r))")
        test.eq(approx(+q, BigRat.atan,     Double.atan), true, "Rational vs Double: atan(\(+q))")
        test.eq(approx(+r, BigFloat.atan,   Double.atan), true, "BigFloat vs Double: atan(\(+r))")
        test.eq(approx(+q, BigRat.cosh,     Double.cosh), true, "Rational vs Double: cosh(\(+q))")
        test.eq(approx(+r, BigFloat.cosh,   Double.cosh), true, "BigFloat vs Double: cosh(\(+r))")
        test.eq(approx(+q, BigRat.sinh,     Double.sinh), true, "Rational vs Double: sinh(\(+q))")
        test.eq(approx(+r, BigFloat.sinh,   Double.sinh), true, "BigFloat vs Double: sinh(\(+r))")
        test.eq(approx(+q, BigRat.tanh,     Double.tanh), true, "Rational vs Double: tanh(\(+q))")
        test.eq(approx(+r, BigFloat.tanh,   Double.tanh), true, "BigFloat vs Double: tanh(\(+r))")
        test.eq(approx(+q, BigRat.asinh,    Double.asinh), true, "Rational vs Double: asinh(\(+q))")
        test.eq(approx(+r, BigFloat.asinh,  Double.asinh), true, "BigFloat vs Double: asinh(\(+r))")
        if q != 0 {
            test.eq(approx(-q, BigRat.exp,      Double.exp), true,  "Rational vs Double: exp(\(-q))")
            test.eq(approx(-r, BigFloat.exp,    Double.exp), true,  "BigFloat vs Double: exp(\(-r))")
            test.eq(approx(-q, BigRat.cos,      Double.cos), true,  "Rational vs Double: cos(\(-q))")
            test.eq(approx(-r, BigFloat.cos,    Double.cos), true,  "BigFloat vs Double: cos(\(-r))")
            test.eq(approx(-q, BigRat.sin,      Double.sin), true,  "Rational vs Double: sin(\(-q))")
            test.eq(approx(-r, BigFloat.sin,    Double.sin), true,  "BigFloat vs Double: sin(\(-r))")
            test.eq(approx(-q, BigRat.tan,      Double.tan), true,  "Rational vs Double: tan(\(-q))")
            test.eq(approx(-r, BigFloat.tan,    Double.tan), true,  "BigFloat vs Double: tan(\(-r))")
            test.eq(approx(-q, BigRat.atan,     Double.atan),true,  "Rational vs Double: atan(\(-q))")
            test.eq(approx(-r, BigFloat.atan,   Double.atan),true,  "BigFloat vs Double: atan(\(-r))")
            test.eq(approx(-q, BigRat.asinh,   Double.asinh),true,  "Rational vs Double: asinh(\(-q))")
            test.eq(approx(-r, BigFloat.asinh, Double.asinh),true,  "BigFloat vs Double: asinh(\(-r))")
        }
        if q < 1 {
            test.eq(approx(+q, BigRat.atanh,    Double.atanh), true,  "Rational vs Double: atanh(\(+q))")
            test.eq(approx(+r, BigFloat.atanh,  Double.atanh), true,  "BigFloat vs Double: atanh(\(+r))")
            if q != 0 {
                test.eq(approx(-q, BigRat.atanh,    Double.atanh), true,  "Rational vs Double: atanh(\(-q))")
                test.eq(approx(-r, BigFloat.atanh,  Double.atanh), true,  "Rational vs Double: atanh(\(-r))")
            }
        }
        if q <= 1 {
            test.eq(approx(+q, BigRat.acos,     Double.acos), true, "Rational vs Double: acos(\(+q))")
            test.eq(approx(+r, BigFloat.acos,   Double.acos), true, "BigFloat vs Double: acos(\(+r))")
            test.eq(approx(+q, BigRat.asin,     Double.asin), true, "Rational vs Double: asin(\(+q))")
            test.eq(approx(+r, BigFloat.asin,   Double.asin), true, "BigFloat vs Double: asin(\(+r))")
            if q != 0 {
                test.eq(approx(-q, BigRat.acos,     Double.acos), true,   "Rational vs Double: acos(\(-q))")
                test.eq(approx(-r, BigFloat.acos,   Double.acos), true,   "BigFloat vs Double: acos(\(-r))")
                test.eq(approx(-q, BigRat.asin,     Double.asin), true,   "Rational vs Double: asin(\(-q))")
                test.eq(approx(-r, BigFloat.asin,   Double.asin), true,   "BigFloat vs Double: asin(\(-r))")
            }
        } else {
            test.eq(approx(+q, BigRat.acosh,    Double.acosh), true,    "Rational vs Double: acosh(\(+q))")
            test.eq(approx(+r, BigFloat.acosh,  Double.acosh), true,    "BigFloat vs Double: acosh(\(+r))")
            if q != 0 {
                test.eq(approx(-q, BigRat.acosh,    Double.acosh), true,    "Rational vs Double: acosh(\(-q))")
                test.eq(approx(-r, BigFloat.acosh,  Double.acosh), true,    "BigFloat vs Double: acosh(\(r))")
            }
        }
    }
    for y in [-1.0, -0.0, +0.0, +1.0] {
        for x in [-1.0, -0.0, +0.0, +1.0] {
            let qx = BigRat(x)
            let qy = BigRat(y)
            test.eq(approx(qy, qx, BigRat.atan2,    Double.atan2), true, "Rational vs Double: atan2(\(y), \(x))")
            let rx = BigFloat(x)
            let ry = BigFloat(y)
            test.eq(approx(ry, rx, BigFloat.atan2,  Double.atan2), true,  "BigFloat vs Double: atan2(\(y), \(x))")
        }
    }
}