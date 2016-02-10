/*:
# Welcome to PONS!

Welcome to pons, a protocol-oriented number system for swift, purely by swift.

![](https://github.com/dankogai/swift-pons/raw/master/typetree.png)

## Good old day with C

You used to have functions that does the same thing, but with different types.
Try 'man pow` from your Terminal.app.

    SYNOPSIS
        #include <math.h>

        double
        pow(double x, double y);

        long double
        powl(long double x, long double y);

        float
        powf(float x, float y);

`pow` for `double`, `powf` for `float`, and `powl` for `long double`. 
How diligent last century programmers are!  We 21st-centry programmers
should definitely be lazier than that


> [Laziness]:  The quality that makes you go to great effort to reduce overall energy expenditure. It makes you write labor-saving programs that other people will find useful and document what you wrote so you don't have to answer so many questions about it.

[Laziness]: http://threevirtues.com

## enter Swift

With swift, all you need is `pow` once you import `Cocoa` (or `Foundation` or `Darwin`, Or `GLibc` if you are on Linux).

*/
import Cocoa    // this is an OSX playground
let twelveTet = pow(2.0, 1.0/12)
pow(Float(twelveTet), 12)           // not exactly 2.0 but you get the point
/*:

Nice! but what do you do implement your own function for different types?

    func fib(n:Int8)->Int8   { return n < 2 ? i : fib(n-2)+fib(n-1) }
    func fib(n:Int16)->Int16 { return n < 2 ? i : fib(n-2)+fib(n-1) }
    func fib(n:Int32)->Int32 { return n < 2 ? i : fib(n-2)+fib(n-1) }
    func fib(n:Int64)->Int64 { return n < 2 ? i : fib(n-2)+fib(n-1) }
    // hey, don't forget UInt(8|16|32|64)?

Being tired of all these, you recall generic functions.  And you come up with this.

    func fib<T>(i:T)->T { return i < 2 ? i : fib(n-2)+fib(n-1) }

Will that work?  Of course not!  God knows how to compare `T` against `2` and 
add `T` to `T`.  You have to teach Swift T can be added:

    func fib<T:GoodType>(i:T)->T { return i < 2 ? i : fib(n-2)+fib(n-1) }

But where is that `GoodType` that makes that possible?

That is what `PONS` is exactly for.

*/
import PONS     // make sure you have built the framework before this!

func fib<T:POInteger>(n:T)->T { // with a little better algorithm
    if n < T(2) { return n }
    var (a, b) = (T(0), T(1))
    for _ in 2...n {
        (a, b) = (b, a+b)
    }
    return b
}
//: Let's see if it really works.
let F11 = fib(11 as Int8)
let F13 = fib(13 as UInt8)
let F23 = fib(23 as Int16)
let F24 = fib(24 as UInt16)
let F46 = fib(46 as Int32)
let F47 = fib(47 as UInt32)
let F92 = fib(92 as Int64)
let F93 = fib(93 as UInt64)
/*:
Option+Click FXX to see their types are all different.

Write once, run on every type!

And I mean every type, not just Swift-builtin.  Let's try it on `BigInt`.
Yes, that's part of PONS.
*/
let F666 = fib(666 as BigInt)
/*:

That's the strength of protocol-oriented programming.
PONS is written to bring the power of POP to numbers.

*/
//: [Next](@next)
