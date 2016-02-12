//: [Previous](@previous)

import PONS

func mersenneNumber(n:Int)->BigInt {
    return 1.asBigInt! << n.asBigInt! - 1
}
func primeSearch(n:Int, onfound:(Int)->()) {
    (2...n).filter{ $0.isPrime }.forEach(onfound)
}
func mersennePrimeSearch(n:Int)->() {
    primeSearch(n) { p in
        let mp = mersenneNumber(p)
        if !mp.isPrime { return }
        print("M\(p) = \(mp)")

    }
}
mersennePrimeSearch(127)
UInt8.max.prevPrime!.nextPrime//: [Next](@next)
