//
//  xtra.swift
//  test
//
//  Created by Dan Kogai on 2/17/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

func testXtra(test:TAP) {
    // Bool.xor
    test.eq(Bool.xor(true,   true), false,  "xor(true,   true) == false")
    test.eq(Bool.xor(true,  false), true,   "xor(true,  false) ==  true")
    test.eq(Bool.xor(false,  true), true,   "xor(false, false) ==  true")
    test.eq(Bool.xor(false, false), false,  "xor(false, false) == false") 
}