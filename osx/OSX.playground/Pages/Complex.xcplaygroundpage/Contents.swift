//: [Previous](@previous)
/*:

# Complex Numbers

Here we discuss how PONS handles [complex number]s

[complex number]: https://en.wikipedia.org/wiki/Complex_number
*/
// import Cocoa // we don't need this here.
import PONS     // because we have this!
/*:

## Gaussian Integer

Complex numbers whose real and imaginary parts are both integers are 
known as a [Gaussian integer]s.

[Gaussian integer]: https://en.wikipedia.org/wiki/Gaussian_integer

In PONS, they are `GaussianInt<POInt>`.

*/
let zi = GaussianInt(3, 4)  // We have an initializer like this
zi  == 3 + 4.i              // But you would love this better instead.
zi.conj
zi.norm
zi.real
zi.imag
zi + zi
zi - zi
zi * zi
zi / zi
zi.asReal               // imag part is nonzero so nil
(zi / zi).asReal        // imag part is now zero so real
/*:
Note `.abs` and `.arg` are missing because they are not usually integers.
See what happens when you uncomment the following:
*/
// zi.abs
// zi.arg
/*:

## Complex Real

In PONS, `Complex` refers to `Complex<POReal>`.

*/
let zr = 3.0 + 4.0.i    //  Complex<Double>
zr + zr
zr - zr
zr * zr
zr / zr
//: Being Real, we now have `.abs`, `.arg`, and `.proj`, too!
zr.abs
zr.arg
zr.proj
//: you can also construct `Complex` via polar coodinates.
let zp = Complex(abs:5, arg:Double.atan2(4, 3))
zr == zp       // sadly false
(zr - zp).abs  // though very close
/*:

## Any POReal will do!

In PONS, `Complex` is not limited to  `Complex<Double>`.  Any `POReal` can be `Complex`.

*/
let zq = 1.over(3) + 2.over(3).i
/*:
## No conversion required with POReal

Not only `Complex<POReal>` supports operations with one another,
it supports direct operation with `POReal`.

*/
zi * 2
zr * Double.PI
zq * 3.over(2)
/*:
### Elementary functions

Elementary functions like `sqrt`, `exp`, `log`, `cos`, `sin` are available as static functions.
Since the type name is explicit,  it always evaluates the arguments in complex context.

*/
Double.sqrt(-1)     // too sad.
Complex.sqrt(-1)    // are you happy now?
Complex.exp(Double.PI.i)    // sadly not -1.0+0.0.i
Complex.log(-1)             // happily Double.PI
({ θ in
    let cos = Complex.cos(θ)
    let sin = Complex.sin(θ)
    cos*cos + sin*sin       // not 1.0+0.0.i but close
})(zr)

//: [Next](@next)
