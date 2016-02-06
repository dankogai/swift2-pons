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
///     public protocol PONumber :  Equatable,
///                                 CustomStringConvertible,
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
public protocol PONumber :  Equatable, Hashable, CustomStringConvertible,
                            IntegerLiteralConvertible,
                            _BuiltinIntegerLiteralConvertible
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
    /// default initializers just Int()s the argument.
    /// in practice you should override them, especially U?Int64 and Double
    public init(_ v:UInt64) { self.init(Int(v)) }       //  override this for the best result
    public init(_ v:UInt32) { self.init(v.toUIntMax()) }
    public init(_ v:UInt16) { self.init(v.toUIntMax()) }
    public init(_ v:UInt8)  { self.init(v.toUIntMax()) }
    public init(_ v:UInt)   { self.init(v.toUIntMax()) }
    public init(_ v:Int64)  { self.init(Int(v)) }       // override this for the best result
    public init(_ v:Int32)  { self.init(v.toIntMax()) }
    public init(_ v:Int16)  { self.init(v.toIntMax()) }
    public init(_ v:Int8)   { self.init(v.toIntMax()) }
    /// IntegerLiteralConvertible by Default
    public init(integerLiteral:Int) {
        self.init(integerLiteral)
    }
    /// _BuiltinIntegerLiteralConvertible by Default
    public init(_builtinIntegerLiteral:_MaxBuiltinIntegerType) {
        self.init(UInt(_builtinIntegerLiteral: _builtinIntegerLiteral))
    }
    /// CustomStringConvertible by Default
    public var description: String {
        return self.toIntMax().description
    }
    /// Hashable by default
    public var hashValue : Int {    // slow but steady
        return self.description.hashValue
    }
    /// give away these converters
    // converters
    public var asUInt64:UInt64  { return UInt64(self.toIntMax()) }
    public var asUInt32:UInt32  { return UInt32(self.toIntMax()) }
    public var asUInt16:UInt16  { return UInt16(self.toIntMax()) }
    public var asUInt8:UInt8    { return UInt8(self.toIntMax()) }
    public var asUInt:UInt      { return UInt(self.toIntMax()) }
    public var asInt64:Int64    { return Int64(self.toIntMax()) }
    public var asInt32:Int32    { return Int32(self.toIntMax()) }
    public var asInt16:Int16    { return Int16(self.toIntMax()) }
    public var asInt8:Int8      { return Int8(self.toIntMax()) }
    public var asInt:Int        { return Int(self.toIntMax()) }
    public var asDouble:Double  { return Double(self.toIntMax()) }
    public var asFloat:Float    { return Float(self.toIntMax()) }
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
public protocol POSignedNumber : POComparableNumber, SignedNumberType {}
