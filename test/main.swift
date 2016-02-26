//
//  main.swift
//  pons
//
//  Created by Dan Kogai on 2/4/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

#if true

let test = TAP()
testInteger (test)
testReal    (test)
testComplex (test)
testPrime   (test)
testMath    (test)
testXtra    (test)
for (k, v) in POUtil.constants {
    print("\(k) = \(v)")
}
test.done()

#else

//print("π ≅", BigFloat.pi(256, verbose:true).toFPString())
//print(POUtil.constants)
//func machin(p:Int)->BigRat {
//    return 4*BigRat.atan(BigInt(1).over(5), precision:p) - BigRat.atan(BigInt(1).over(239), precision:p)
//}
//print(4 * machin(512))
    
#endif
