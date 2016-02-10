/*:
# Rationale

Let me briefly describe why I came up with project.

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

## FAQ

### Q. Swift already has tons of protocols built-in like [IntegerType] and [FloatingPointType].  Why do you reinvent these?

[IntegerType]: http://swiftdoc.org/v2.1/protocol/IntegerType/
[FloatingPointType]: http://swiftdoc.org/v2.1/protocol/FloatingPointType/
[IntegerArithmeticType]: http://swiftdoc.org/v2.1/protocol/IntegerArithmeticType/
[Comparable]: http://swiftdoc.org/v2.1/protocol/Comparable/
[AbsoluteValuable]: http://swiftdoc.org/v2.1/protocol/AbsoluteValuable/

A.  I wish I could.  As a matter of fact I tried to do so when I started.  It turns out the protocol tree Swift 2.1 offers is not fit for the Protocol-Oriented Number System.  For instance, [FloatingPointType] lacks arithmetic operators.  They can be found in [IntegerArithmeticType] but it includes `%`, something that is not essential for real-number arithmetics

Besides, where are you going to fit `Complex`?  It is the queen of the numbers but definitely not [Comparable].  It is absolute-valuable but Swift says [AbsoluteValuable] is also [Comparable].

I am pretty sure Swift insiders are aware of this issue that should be addressed.  I found the following in the swift-evolution mailing list.

<https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20151214/002445.html>
>  I have been working for some time on a rewrite of all the integer types and protocols <https://github.com/apple/swift/blob/master/test/Prototypes/Integers.swift.gyb>.  One goal of this effort is to enable operations on mixed integer types, which as you can see is partially completed.  In-place arithmetic (anInt32 += aUInt64) is next.  Another important goal is to make the integer protocols actually useful for writing generic code, instead of what they are today: implementation artifacts used only for code sharing.  As another litmus test of the usefulness of the resulting protocols, the plan is to implement BigInt in terms of the generic operations defined on integers, and make BigInt itself conform to those protocols.

Maybe I am a litte too impatient.  But here it is.

> [Impatience]:  The anger you feel when the computer is being lazy. This makes you write programs that don't just react to your needs, but actually anticipate them. Or at least pretend to.

[Impatience]: http://threevirtues.com

*/
//: [Next](@next)
