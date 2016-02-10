import Cocoa    // this is an OSX playground
import PONS     // make sure you have built the framework before this!
//: Playground - noun: a place where people can play
let bn = BigInt(2) ** 127
let bq = BigInt(1).over(bn)
let bz = bq + bq.i
print(bz + bz)
print(bz - bz)
print(bz * bz)
print(bz / bz)
print(bz.conj)
print(bz.abs)
print(bz.arg)
