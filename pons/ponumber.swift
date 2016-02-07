//
//  ponumber.swift
//  pons
//
//  Created by Dan Kogai on 2/4/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

///
/// Minimum requirement for Protocol-Oriented Numbers.  Defined as follows
///
///     public protocol PONumber :  Equatable, Hashable, CustomStringConvertible,
///                                 IntegerLiteralConvertible,
///                                 _BuiltinIntegerLiteralConvertible
///                                 Hashable
///     {
///         init(_:Self)                // to copy itself
///         init(_:Int)                 // to convert from at least Int
///         func toIntMax()->IntMax     // to reverse-convert to IntMax = Int64
///         func +(_:Self,_:Self)->Self // to add each other
///         func -(_:Self,_:Self)->Self // to subtract each other
///         func *(_:Self,_:Self)->Self // to multiply each other
///         func /(_:Self,_:Self)->Self // to divide each other
///     }
///
/// But don't worry about built-in protocols it inherits.
/// Defaults are given later via protocol extension.
///
/// all built-ins number types are extended to conform thereto.
///
/// Note it is NOT `Comparable`.
/// Otherwise you can't make complex numbers conform to this.
public protocol PONumber :  Equatable, Hashable, CustomStringConvertible
{
    init(_:Self)
    init(_:Int)
    func toIntMax()->IntMax
    func +(_:Self,_:Self)->Self
    func -(_:Self,_:Self)->Self
    func *(_:Self,_:Self)->Self
    func /(_:Self,_:Self)->Self
}
public extension PONumber {
    /// CustomStringConvertible by Default
    public var description: String {
        return self.toIntMax().description
    }
    /// Hashable by default
    public var hashValue : Int {    // slow but steady
        return self.description.hashValue
    }
 }
/// Equatable by default but you should override this!
public func ==<T:PONumber>(lhs:T, rhs:T)->Bool {
    return lhs.toIntMax() == rhs.toIntMax()
}
public func !=<T:PONumber>(lhs:T, rhs:T)->Bool {
    return !(lhs == rhs)
}
// give them all way!
public func +=<T:PONumber>(inout lhs:T, rhs:T) {
    lhs = lhs + rhs
}
public func -=<T:PONumber>(inout lhs:T, rhs:T) {
    lhs = lhs - rhs
}
public func *=<T:PONumber>(inout lhs:T, rhs:T) {
    lhs = lhs * rhs
}
public func /=<T:PONumber>(inout lhs:T, rhs:T) {
    lhs = lhs / rhs
}
/// Comparable Numbers
public protocol POComparableNumber : PONumber, Comparable {}
///
/// `POSignedNumber` = `PONumber` + `SignedNumberType`
///
public protocol POSignedNumber : POComparableNumber, SignedNumberType
{
    var isSignMinus:Bool { get }
    prefix func -(_:Self)->Self
    func -(_:Self, _:Self)->Self
}
