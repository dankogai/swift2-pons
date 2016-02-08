[![build status](https://secure.travis-ci.org/dankogai/swift-pons.png)](http://travis-ci.org/dankogai/swift-pons)

# swift-pons
Protocol-Oriented Number System in Pure Swift

![typetree](./typetree.png)

## SYNOPSIS

````swift
let bn = BigInt(2) ** 128
// 340282366920938463463374607431768211456
let bq = BigInt(1).over(bn)
// (1/340282366920938463463374607431768211456)
let bz = bq + bq.i
// ((1/340282366920938463463374607431768211456)+(1/340282366920938463463374607431768211456).i)
bz + bz
// ((1/170141183460469231731687303715884105728)+(1/170141183460469231731687303715884105728).i)
bz - bz
// ((0/1)+(0/1).i)
bz * bz
// ((0/1)+(1/57896044618658097711785492504343953926634992332820282019728792003956564819968).i)
bz / bz
// ((1/1)+(0/1).i)
````
