import UIKit    // this is a tvOS playground
// import PONS  // commmented out because sources are symlinked to Sources/
//: Playground - noun: a place where people can play
let bn = BigInt(2) ** 128
let bq = BigInt(1).over(bn)
let bz = bq + bq.i
print(bz + bz)
print(bz - bz)
print(bz * bz)
print(bz / bz)
print(bz.conj)
print(bz.abs)
print(bz.arg)
