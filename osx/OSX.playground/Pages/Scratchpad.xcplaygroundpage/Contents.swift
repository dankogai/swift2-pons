//: [Previous](@previous)
import PONS
import Foundation

public class PiHex : SequenceType {
    public init(){}
    public func generate()->AnyGenerator<Int> {
        var x = BigInt(0).over(1)
        var i = 1
        return anyGenerator {
            let n:BigInt = (120*i-89)*i+16
            let d:BigInt = (((512*i-1024)*i+712)*i-206)*i+21
            x *= BigRat(16)
            x += n.over(d)
            x = x % BigRat(1)
            i += 1
            return (BigInt(16) * x).toMixed().0.asInt
        }
    }
}

/*

for i in UInt(Int.max-64)...UInt(Int.max) {
print(i, "=", UInt.factor(i, verbose: true).map{$0.description}.joinWithSeparator("*"))
}

UIntMax.factor(4611685846628697223, verbose:true)
UIntMax.factor(10023859281455311421, verbose:true)
BigUInt.factor("63375401385616362433", verbose:true)

BigInt("3317044064679887385961981").nextPrime
BigInt("4547337172376300111955330758342147474062293202868155909393").isPrime
BigInt("4547337172376300111955330758342147474062293202868155909489").isPrime
BigInt("3317044064679887385961981").nextPrime!.isPrime
*/
