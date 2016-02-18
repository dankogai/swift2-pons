//
//  main.swift
//  pons
//
//  Created by Dan Kogai on 2/4/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

// make (T,S) equatable just for tests
// oh... Swift 2.2 on Linux puked on this :-(
//func ==<T:Equatable,S:Equatable>(lhs:(T,S), rhs:(T,S))->Bool {
//    return lhs.0 == rhs.0 && lhs.1 == rhs.1
//}

#if true
    let test = TAP()
    testInteger (test)
    testReal    (test)
    testComplex (test)
    testMath    (test, num:16)
    testPrime   (test)
    testXtra    (test)
    // print(POUtil.constants)
    test.done()
#else

//print("π ≅", BigRat.pi(64, verbose:true).toFPString())
//print("π ≅", BigRat.pi(64, verbose:true).toFPString())
//print("π ≅", BigRat.pi(128, verbose:true).toFPString())
//print("π ≅", BigRat.pi(128, verbose:true).toFPString())
//print("π ≅", BigRat.pi(256, verbose:true).toFPString())
//print("π ≅", BigRat.pi(512, verbose:true).toFPString())
//print("π ≅", BigRat.pi(1024, verbose:true).toFPString())
//print(POUtil.constants)
//func machin(p:Int)->BigRat {
//    return 4*BigRat.atan(BigInt(1).over(5), precision:p) - BigRat.atan(BigInt(1).over(239), precision:p)
//}
//print(4 * machin(512))
//print(Complex.exp(BigRat.pi().i))
//print(Complex.exp(BigRat.pi(96,verbose:true).i))
//print(Complex.exp(BigRat.pi(128,verbose:true).i))
//print(Complex.exp(BigRat.pi(192,verbose:true).i))

//let u256max = BigUInt(1)<<256-1
//let i128max = BigUInt(1)<<127-1
//var prev = BigUInt.divmodLongBit(u256max, i128max)
//var curr = BigUInt.divmodNR(u256max, i128max)
//print("BigUInt.divmod(\(u256max) / \(i128max)) == \(curr)")
//for i in 0..<1024 {
//    prev = BigUInt.divmodLongBit(u256max << BigUInt(i), i128max + BigUInt(2*i))
//    curr = BigUInt.divmodNR(u256max << BigUInt(i), i128max + BigUInt(2*i))
//    if prev.0 != curr.0 || prev.1 != curr.1 {
//        fatalError()
//    }
//}
#endif
