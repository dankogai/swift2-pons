//
//  ponumber.swift
//  pons
//
//  Created by Dan Kogai on 2/4/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

///
/// Minimum requirement for Protocol-Oriented Numbers.
///
///     public protocol PONumber : Equatable {
///         init(_:Self)    // self-initializable
///         init(_:Int)     // accept built-in number types
///         init(_:UInt)
///         init(_:Double)
///         func +(_:Self,_:Self)->Self // addable
///         func -(_:Self,_:Self)->Self // subtractable
///         func *(_:Self,_:Self)->Self // multipliable
///         func /(_:Self,_:Self)->Self // divisible
///     }
///
/// Note it is NOT `Comparable`.
/// Otherwise you can't make complex numbers conform to this.
public protocol PONumber : Equatable {
    init(_:Self)
    init(_:Int)
    init(_:UInt)
    init(_:Double)
    func +(_:Self,_:Self)->Self
    func -(_:Self,_:Self)->Self
    func *(_:Self,_:Self)->Self
    func /(_:Self,_:Self)->Self
}

///
/// `POSignedNumber` = `PONumber` + `SignedNumberType`
///
public protocol POSignedNumber : PONumber, SignedNumberType {}