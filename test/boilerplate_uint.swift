//
//  boilerplate_uint.swift
//  test
//
//  Created by Dan Kogai on 2/24/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

///
/// Boilerplate Unsinged Integer
///
/// Does nothing but conform to `POUInt`
///
/// Replace `BPUInt` with the type name of your choice
/// and replace `fatalError("TODO")` with your implementation
///
public struct BPUInt : POUInt {
    public typealias IntType = Int
    public static let precision = 64
    public static let allZeros = BPUInt(0)
    public init(_ s:BPUInt) {
        fatalError("TODO")
    }
    public init(_ u:UIntMax) {
        fatalError("TODO")
    }
    public init(_ u:UInt) {
        fatalError("TODO")
    }
    public init(_  i:Int) {
        fatalError("TODO")
    }
    public func toUIntMax()->UIntMax {
        fatalError("TODO")
    }
    public func toIntMax()->IntMax {
        fatalError("TODO")
    }
    public var msbAt:Int {
        fatalError("TODO")
    }
    public var asSigned:IntType? {
        fatalError("TODO")
    }
    public static func addWithOverflow(lhs:BPUInt, _ rhs:BPUInt)->(BPUInt, overflow:Bool) {
        fatalError("TODO")
    }
    public static func subtractWithOverflow(lhs:BPUInt, _ rhs:BPUInt)->(BPUInt, overflow:Bool) {
        fatalError("TODO")
    }
    public static func multiplyWithOverflow(lhs:BPUInt, _ rhs:BPUInt)->(BPUInt, overflow:Bool) {
        fatalError("TODO")
    }
    public static func divmod(lhs:BPUInt, _ rhs:BPUInt)->(BPUInt, BPUInt) {
        fatalError("TODO")
    }
    public static func divideWithOverflow(lhs:BPUInt, _ rhs:BPUInt)->(BPUInt, overflow:Bool) {
        fatalError("TODO")
    }
    public static func remainderWithOverflow(lhs:BPUInt, _ rhs:BPUInt)->(BPUInt, overflow:Bool) {
        fatalError("TODO")
    }
}
public func ==(lhs:BPUInt, rhs:BPUInt)->Bool {
    fatalError("TODO")
}
public func <(lhs:BPUInt, rhs:BPUInt)->Bool {
    fatalError("TODO")
}
public prefix func ~(bs:BPUInt)->BPUInt {
    fatalError("TODO")
}
public func &(lhs:BPUInt, rhs:BPUInt)->BPUInt {
    fatalError("TODO")
}
public func |(lhs:BPUInt, rhs:BPUInt)->BPUInt {
    fatalError("TODO")
}
public func ^(lhs:BPUInt, rhs:BPUInt)->BPUInt {
    fatalError("TODO")
}
public func <<(lhs:BPUInt, rhs:BPUInt)->BPUInt {
    fatalError("TODO")
}
public func >>(lhs:BPUInt, rhs:BPUInt)->BPUInt {
    fatalError("TODO")
}
