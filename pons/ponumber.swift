//
//  ponumber.swift
//  pons
//
//  Created by Dan Kogai on 2/4/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

/// Minimum requirement for Protocol-Oriented Numbers
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

public protocol POSignedNumber : PONumber, SignedNumberType {
    
}