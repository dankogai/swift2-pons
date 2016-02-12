//: [Previous](@previous)
import PONS
/*: # Primarity Test

Primarity test is included via `xtra_prime.swift`.  If you don't need just exclude that from your project.

Let's see how it works.
*/
//: ## self.isPrime
(-1).isPrime
0.isPrime
2.isPrime
42.isPrime
Int32.max.isPrime           // M31
UInt32.max.isPrime
(1<<61-1).isPrime           // M61
UIntMax.max.isPrime
(BigInt(1)<<89-1).isPrime   // M89
//: ## self.nextPrime and self.prevPrime
2.prevPrime                         // no prime before 2
2.nextPrime
UIntMax.max.prevPrime               // the largest prime possible for built-in number type
UIntMax.max.nextPrime               // no more for UIntMax
UIntMax.max.asBigUInt!.nextPrime    // but you can go beyond that with PONS
//: ## Extra: Mersenne Prime Search
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
// mersennePrimeSearch(127)
//: [Next](@next)
