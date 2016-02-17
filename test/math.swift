//
//  math.swift
//  test
//
//  Created by Dan Kogai on 2/17/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

// Approximation tests for unary functions
func approx(q:BigRat, _ fq:(BigRat,precision:Int)->BigRat, _ fd:(Double,precision:Int)->Double)->Bool {
    // print(fq(q,precision:64).toDouble() - fd(q.toDouble()))
    let qd = fq(q,precision:64).toDouble()
    let dd = fd(q.toDouble(),precision:52)
    if qd == dd { return true }
    let diff = Swift.abs(qd - dd) / Swift.abs(qd + dd)
    if diff > 0x2p-52 {
        print("qd = \(qd), dd=\(dd), diff=\(diff)")
        return false
    }
    return true
}
// Approximation tests for binary functions
func approx(q:BigRat, _ r:BigRat, _ fq:(BigRat,BigRat,precision:Int)->BigRat, _ fd:(Double,Double,precision:Int)->Double)->Bool {
    // print(fq(q,precision:64).toDouble() - fd(q.toDouble()))
    let qd = fq(q,r, precision:64).toDouble()
    let dd = fd(q.toDouble(),r.toDouble(), precision:52)
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
        test.eq(approx(+q, BigRat.sqrt, Double.sqrt), true,  "Rational vs Double: sqrt(\(+q))")
        test.eq(approx(+q, BigRat.log,  Double.log),  true,  "Rational vs Double: log(\(+q))")
        test.eq(approx(+q, BigRat.exp,  Double.exp),  true,  "Rational vs Double: exp(\(+q))")
        test.eq(approx(+q, BigRat.cos,  Double.cos),  true,  "Rational vs Double: cos(\(+q))")
        test.eq(approx(+q, BigRat.sin,  Double.sin),  true,  "Rational vs Double: sin(\(+q))")
        test.eq(approx(+q, BigRat.tan,  Double.tan),  true,  "Rational vs Double: tan(\(+q))")
        test.eq(approx(+q, BigRat.atan, Double.atan), true,  "Rational vs Double: atan(\(+q))")
        test.eq(approx(+q, BigRat.cosh,  Double.cosh),  true,  "Rational vs Double: cosh(\(+q))")
        test.eq(approx(+q, BigRat.sinh,  Double.sinh),  true,  "Rational vs Double: sinh(\(+q))")
        test.eq(approx(+q, BigRat.tanh,  Double.tanh),  true,  "Rational vs Double: tanh(\(+q))")
        test.eq(approx(+q, BigRat.asinh,  Double.asinh),  true,  "Rational vs Double: asinh(\(+q))")
        if q != 0 {
            test.eq(approx(-q, BigRat.exp,  Double.exp),  true,  "Rational vs Double: exp(\(-q))")
            test.eq(approx(-q, BigRat.cos,  Double.cos),  true,  "Rational vs Double: cos(\(-q))")
            test.eq(approx(-q, BigRat.sin,  Double.sin),  true,  "Rational vs Double: sin(\(-q))")
            test.eq(approx(-q, BigRat.tan,  Double.tan),  true,  "Rational vs Double: sin(\(-q))")
            test.eq(approx(-q, BigRat.atan, Double.atan), true,  "Rational vs Double: atan(\(-q))")
            test.eq(approx(-q, BigRat.asinh,  Double.asinh),  true,  "Rational vs Double: asinh(\(-q))")
        }
        if q < 1 {
            test.eq(approx(+q, BigRat.atanh, Double.atanh), true,  "Rational vs Double: atanh(\(+q))")
            if q != 0 {
                test.eq(approx(-q, BigRat.atanh, Double.atanh), true,  "Rational vs Double: atanh(\(-q))")
            }
        }
        if q <= 1 {
            test.eq(approx(+q, BigRat.acos, Double.acos), true,  "Rational vs Double: acos(\(+q))")
            test.eq(approx(+q, BigRat.asin, Double.asin), true,  "Rational vs Double: asin(\(+q))")
            if q != 0 {
                test.eq(approx(-q, BigRat.acos, Double.acos), true,  "Rational vs Double: acos(\(-q))")
                test.eq(approx(-q, BigRat.asin, Double.asin), true,  "Rational vs Double: asin(\(-q))")
            }
        } else {
            test.eq(approx(+q, BigRat.acosh, Double.acosh), true,  "Rational vs Double: acosh(\(+q))")
            if q != 0 {
                test.eq(approx(-q, BigRat.acosh, Double.acosh), true,  "Rational vs Double: acosh(\(-q))")
            }
        }
    }
    let qzero = +BigInt(0).over(1)
    let qone  = +BigInt(1).over(1)
    for y in [-qone, -qzero, +qzero, +qone] {
        for x in [-qone, -qzero, +qzero, +qone] {
            test.eq(approx(y, x, BigRat.atan2, Double.atan2), true,  "Rational vs Double: atan2(\(y), \(x))")
        }
    }

}