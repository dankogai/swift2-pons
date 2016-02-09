#!/usr/bin/env swift
// compile: xcrun -sdk macosx swiftc -O bignum/*.swift benchmark/main.swift
#if os(Linux)
import Glibc
#else
import Foundation
#endif

func now()->Double {
    var tv = timeval()
    gettimeofday(&tv, nil)
    return Double(tv.tv_sec) + Double(tv.tv_usec)/1e6
}

func timeit(count:Int, task:()->())->Double {
    let started = now()
    for _ in 0..<count { task() }
    return now() - started
}

// print("sqrt(2.0)         == \(sqrt(2.0))")
// print("pow(2.0, 0.5)     == \(pow(2.0, 0.5))")
// print("exp(log(2.0)*0.5) == \(exp(log(2.0)*0.5))")


// let count = 1_000_000

// [
//     "sqrt(2.0)         ":timeit(count){ sqrt(2.0) },
//     "pow(2.0, 0.5)    ":timeit(count) { pow(2.0, 0.5) },
//     "exp(log(2.0)*0.5)":timeit(count) { exp(log(2.0)*0.5) }
// ].forEach {
//     print($0.0, ":\t", $0.1)
// }

print( (BigInt(1) << 127 - 1).isPrime )
let t = timeit(10) { (BigInt(1) << 127 - 1).isPrime }
print(t)
