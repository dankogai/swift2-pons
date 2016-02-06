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
var x = Int.power(3, 3){ $0 + $1 }
x

