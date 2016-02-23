//: [Previous](@previous)

import PONS

//

Double.exp(709.782712893384)    // beyond this point it is infinite to Double
BigFloat.exp(709.782712893384)  // till this point BigFloat follows Double

Double.exp(709.782712893385)    // end of the universe to Double
BigFloat.exp(709.782712893385)  // But the universe is larger than that for BigFloat

0x1p-1074 / 2
print(BigFloat(0x1p-1074) / 2)  // see the console below//: [Next](@next)
