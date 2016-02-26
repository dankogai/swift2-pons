//
//  boilerplate_int.swift
//  test
//
//  Created by Dan Kogai on 2/26/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

public struct BPInt : POInt {
    public typealias UIntType = UInt
    public static let precision = 63
    public static let allZeros = BPInt(0)
    public init(_ s:BPInt) {
        fatalError("TODO")
    }
    public init(_ u:UInt) {
        fatalError("TODO")
    }
    public init(_  i:Int) {
        fatalError("TODO")
    }
    public func toIntMax()->IntMax {
        fatalError("TODO")
    }
    public var msbAt:Int {
        fatalError("TODO")
    }
    public var asUnsigned:UIntType? {
        fatalError("TODO")
    }
    public static func addWithOverflow(lhs:BPInt, _ rhs:BPInt)->(BPInt, overflow:Bool) {
        fatalError("TODO")
    }
    public static func subtractWithOverflow(lhs:BPInt, _ rhs:BPInt)->(BPInt, overflow:Bool) {
        fatalError("TODO")
    }
    public static func multiplyWithOverflow(lhs:BPInt, _ rhs:BPInt)->(BPInt, overflow:Bool) {
        fatalError("TODO")
    }
    public static func divmod(lhs:BPInt, _ rhs:BPInt)->(BPInt, BPInt) {
        fatalError("TODO")
    }
    public static func divideWithOverflow(lhs:BPInt, _ rhs:BPInt)->(BPInt, overflow:Bool) {
        fatalError("TODO")
    }
    public static func remainderWithOverflow(lhs:BPInt, _ rhs:BPInt)->(BPInt, overflow:Bool) {
        fatalError("TODO")
    }
}
public prefix func -(i:BPInt)->BPInt {
    fatalError("TODO")
}
public func ==(lhs:BPInt, rhs:BPInt)->Bool {
    fatalError("TODO")
}
public func <(lhs:BPInt, rhs:BPInt)->Bool {
    fatalError("TODO")
}
public prefix func ~(bs:BPInt)->BPInt {
    fatalError("TODO")
}
public func &(lhs:BPInt, rhs:BPInt)->BPInt {
    fatalError("TODO")
}
public func |(lhs:BPInt, rhs:BPInt)->BPInt {
    fatalError("TODO")
}
public func ^(lhs:BPInt, rhs:BPInt)->BPInt {
    fatalError("TODO")
}
public func <<(lhs:BPInt, rhs:BPInt)->BPInt {
    fatalError("TODO")
}
public func >>(lhs:BPInt, rhs:BPInt)->BPInt {
    fatalError("TODO")
}
