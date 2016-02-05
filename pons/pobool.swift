//
//  pobool.swift
//  pons
//
//  Created by Dan Kogai on 2/5/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

public extension Bool {
    /// - returns: !b
    public static func not(b:Bool)->Bool { return !b }
    /// - returns: lhs || rhs
    public static func  or(lhs:Bool, _ rhs:Bool)->Bool { return lhs || rhs }
    /// - retuns: lhs && rhs
    public static func and(lhs:Bool, _ rhs:Bool)->Bool { return lhs && rhs }
    /// - returns: lhs ^^ rhs // FYI ^^ is non-standard
    public static func xor(lhs:Bool, _ rhs:Bool)->Bool {
        return lhs ? rhs ? false : true : rhs ? true : false
    }
}