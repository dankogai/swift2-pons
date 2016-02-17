//
//  rational.swift
//  test
//
//  Created by Dan Kogai on 2/17/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

//
// Rational
//
func testRational(test:TAP) {
    test.eq("\(+2.over(4))", "(1/2)",  "\"\\(+2.over(4))\" == \"(1/2)\"")
    test.eq("\(-2.over(4))", "-(1/2)", "\"\\(-2.over(4))\" == \"-(1/2)\"")
    test.eq("\(2.over(4)+2.over(4).i)", "((1/2)+(1/2).i)",
        "\"\\(2.over(4)+2.over(4).i)\" == \"((1/2)+(1/2).i)\"")
    test.eq("\(2.over(4)-2.over(4).i)", "((1/2)-(1/2).i)",
        "\"\\(2.over(4)-2.over(4).i)\" == \"((1/2)+(1/2).i)\"")
    test.eq(+2.over(+4), +1.over(2), "+2/+4 == +1/2")
    test.eq(+2.over(-4), -1.over(2), "-2/+4 == -1/2")
    test.eq(-2.over(+4), -1.over(2), "+2/-4 == -1/2")
    test.eq(-2.over(-4), +1.over(2), "-2/-4 == +1/2")
    test.ok((+42.over(0)).isInfinite, "\(+42.over(0)) is infinite")
    test.ok((-42.over(0)).isInfinite, "\(-42.over(0)) is infinite")
    test.ok((0.over(0)).isNaN, "\(0.over(0)) is NaN")
    test.ne(0.over(0), 0.over(0), "NaN != NaN")
    test.eq(1.over(2)  <  1.over(3),  false, "+1/2 > +1/3")
    test.eq(1.over(2)  <  1.over(1),   true, "+1/2 < +1/1")
    test.eq(1.over(-2) < 1.over(-3),   true, "-1/2 < -1/3")
    test.eq(1.over(-2) < 1.over(-1),  false, "-1/2 > -1/1")
    test.eq(BigRat(42.195).toFPString(),    "42.1950000000000002842",   "42.195 is really 42.1950000000000002842")
    test.eq(BigRat(42.195).toFPString(16),  "2a.31eb851eb8520",         "42.195 is also 2a.31eb851eb852")
    test.eq(BigRat(42.195).toFPString(10,places:4), "42.1950",  "42.195 to 4 dicimal places")
    test.eq(BigRat(42.195).toFPString(10,places:3), "42.195",   "42.195 to 3 dicimal places")
    test.eq(BigRat(42.195).toFPString(10,places:2), "42.20",    "42.195 to 2 dicimal places")
    test.eq(BigRat(42.195).toFPString(10,places:1), "42.2",     "42.195 to 1 dicimal place")
    test.eq( 1.999999999999.toFPString(10,places:12) , "1.999999999999",
        "1.999999999999.toFPString(10,places:12) is 1.999999999999")
    test.eq(1.999999999999.toFPString(10,places:11),  "2.0",
        "1.999999999999.toFPString(10,places:12) is 2.0")
    ({ q in
        test.eq(q.toMixed().0, -2,            "-14/6 = -2-1/3")
        test.eq(q.toMixed().1, (-1).over(3),  "-14/6 = -2-1/3")
    })((-14).over(6))
}