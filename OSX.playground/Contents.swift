import Cocoa    // this is an OSX playground
//: Playground - noun: a place where people can play

true  ^^  true
true  ^^ false
false ^^  true
false ^^ false

BigInt(2)**1024 == BigInt(1)<<1024

func fib<T:POInteger>(n:T)->T {
    return n < 2 ? n : (2...n).reduce((0, 1)){ p, _ in (p.1, p.0 + p.1) }.1
}
fib(42)
fib(142 as BigInt)
var x = Int.power("X", 3){ $0 + $1 }
x

2 ** 2
2 ** -2.0
1.i == 1.i


({  z in
    z.i
    z.i.i
    z.i.i.i
    z.i.i.i.i
})(42.i)
({  z in
    z.i
    z.i.i
    z.i.i.i
    z.i.i.i.i
    z+z
    z-z
    z/z
    z*z
})(42.195.i)
({  z in
    z.i
    z.i.i
    z.i.i.i
    z.i.i.i.i
    z+z
    z-z
})((BigInt(2)**128-1).i)
({
    var z = Complex(abs:2.0, arg:0.5)
    Complex.norm(z)
    z.abs
    z.arg
    z = -1.0+0.i
    Complex.sqrt(z)
    Complex.sqrt(-1)
    Complex.sqrt(Complex.sqrt(z))
    Complex.exp(M_PI.i)
    Complex.log(Complex.exp(M_PI.i))
    Complex.sin(Double.PI.i)
})()
// func exp<R:POReal>(r:R)->R { return R.exp(r) }
func exp<C:POComplexReal>(z:C)->C { return C.exp(z) }
exp(1.0)
exp(M_PI)
exp(M_PI.i)


42.asBigInt.asRational

/*
Rational(35 as UInt, denominator:42 as UInt) * Rational(2, denominator:3)

BigInt.gcd(2.asBigInt ** 128 - 1, BigInt(UIntMax.max))
BigInt.gcd(81, 7)

42.asRational / 49.asRational
*/



var l = 1.toRational(2)
var r = 1.toRational(3)
l + r
l - r
r - l
l - l*r


l + r.i

