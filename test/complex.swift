//
//  complex.swift
//  test
//
//  Created by Dan Kogai on 2/17/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

func testComplex(test:TAP) {
    // Complex
    ({
        test.eq(1.0-1.0.i, Complex(1.0,-1.0),           "1.0-1.0.i == Complex(1.0,-1.0)")
        test.ok(1.0+0.0.i==1.0,                         "1.0+0.0.i == 1")
        test.ok(    0.0.i==0.0,                         "    0.0.i == 0")
        test.eq(Complex(),     0+0.i,                   "Complex(), 0+0.i")
        test.eq(Complex(), 0.0+0.0.i,                   "Complex(), 0.0+0.0.i")
        test.eq("\(Complex(0.0,+0.0))", "(0.0+0.0.i)",  "0.0+0.0.i")
        test.eq("\(Complex(0.0,-0.0))", "(0.0-0.0.i)",  "0.0-0.0.i")
        var z0 = Complex(abs:10.0, arg:Double.atan2(3.0,4.0))
        test.eq(z0, 8.0+6.0.i      , "Complex(abs:10, arg:atan2(3,4)) == 8.0+6.0.i")
        test.eq(z0 - z0, 0.0+0.0.i , "z - z = 0+0.i")
        test.eq(z0 + z0, z0 * 2    , "z + z = z0*2")
        var z1 = z0; z1 *= z1;
        test.eq(z1, z0*z0  , "var z1=z0; z1*=z1; z1==z0*z0")
        test.eq(z1.abs, z0.abs ** 2  , "z1.abs == z0.abs * z0.abs")
        test.eq(z1.arg, z0.arg *  2  , "z1.arg == z0.abs + z0.arg")
        z1 /= z0;
        test.eq(z1, z0, "z1 /= z0; z1==z0")
    })()
    ({
        let z0 = 0.0 + 0.0.i, zm0 = -z0
        let z1 = 1.0 + 0.0.i, z42_195 = 42.0 + 0.195.i
        test.ok(z0  ** -1.0 == +1.0/0.0, "\(z0 ) ** -1.0 == \(+1.0/0.0)")
        test.ok(zm0 ** -1.0 == -1.0/0.0, "\(zm0) ** -1.0 == \(-1.0/0.0)")
        test.ok(z0  ** -2.0 == +1.0/0.0, "\(z0 ) ** -2.0 == \(+1.0/0.0)")
        test.ok(zm0 ** -2.0 == +1.0/0.0, "\(zm0) ** -2.0 == \(+1.0/0.0)")
        test.eq(z1 ** z42_195,   z1, "\(z1) ** y  == \(z1) // for any y")
        test.eq(z42_195 ** z0,   z1, "x ** \(z0 ) == \(z1) // for any x")
        test.eq(z42_195 ** zm0,  z1, "x ** \(zm0) == \(z1) // for any x")
    })()
    ({
        typealias R=Double
        typealias C=Complex<R>
        test.eq(C.log10(100.i).re, 2.0,             "log10(100.i).re == 2.0")
        test.eq(C.log10(100.i).im, C.log10(1.0.i).im, "log10(100.i).im == log10(1.i).im")
        test.eq(2.0 * 3.0 ** 4.0, 162.0,            "2.0*3.0**4.0 == 2.0 * (3.0 ** 4.0)")
        test.eq((R.E+0.0.i)**R.PI.i, C.exp(R.PI.i), "exp(z) == e ** z")
        test.eq(C.sqrt(-1.0), 1.0.i,                "sqrt(-1) == i")
        test.eq(C.sqrt(2.0.i),    1.0+1.0.i,        "sqrt(2i) == 1+i")
        test.eq(2.0.i **  2.5, -4.0-4.0.i,          "z **  2.5  == z*z*sqrt(z)")
        test.eq(2.0.i **  2.0, -4.0+0.0.i,          "z **  2    == z*z")
        test.eq(2.0.i **  1.5, -2.0+2.0.i,          "z **  1.5  == z*sqrt(z)")
        test.eq(2.0.i **  1.0,  2.0.i,              "z **  1    == z")
        test.eq(2.0.i **  0.5,  1.0+1.0.i,          "z **  0.5  == sqrt(z)")
        test.eq(2.0.i **  0.0,  1.0+0.0.i,          "z **  0    == 1")
        test.eq(2.0.i ** -0.5,  0.5-0.5.i,          "z ** -0.5  == 1/sqrt(z)")
        test.eq(2.0.i ** -1.0, -0.5.i,              "z ** -1    == 1/z")
        test.eq(2.0.i ** -1.5, (-1.0-1.0.i)/4.0,    "z ** -1.5  == 1/(z*sqrt(z))")
        test.eq(2.0.i ** -2.0, -0.25+0.0.i,         "z ** -2    == 1/(z*z)")
        test.eq(2.0.i ** -2.5, (-1.0+1.0.i)/8.0,    "z ** -2.5  == 1/(z*z*sqrt(z))")
        // let r = 0.5, z = C.sqrt(-1.0.i)
        var dict = [0+0.i:"origin"]
        test.ok(dict[0+0.i] == "origin", "Complex as a dictionary key")
    })()
}