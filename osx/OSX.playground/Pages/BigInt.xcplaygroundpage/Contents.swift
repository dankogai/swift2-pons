//: [Previous](@previous)
// import Cocoa // we don't need this here.
import PONS     // because we have this!
/*:
## BigInt = Arbitrary Precision Integer

*/
let int32max = BigInt(0x7fff_ffff)
//: it is `integerLiteralConvertible` so you can go like this, too
let int64max:BigInt = 9223372036854775807
//: it is also `stringLiteralConvertible` so you can use string to init.
let int128max:BigInt = "170141183460469231731687303715884105727"
//: Let's see if M127 is prime :-)
int128max.isPrime
//: [Next](@next)
