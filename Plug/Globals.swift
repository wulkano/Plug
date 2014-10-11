//
//  Constants.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Foundation

let ApiKey = "***REMOVED***"
let PlugErrorDomain = "Plug.ErrorDomain"
let RickRoll = false
let JSONResponseSerializerWithDataKey = "JSONResponseSerializerWithDataKey"

func randInRange(range: Range<Int>) -> Int {
    // arc4random_uniform(_: UInt32) returns UInt32, so it needs explicit type conversion to Int
    // note that the random number is unsigned so we don't have to worry that the modulo
    // operation can have a negative output
    return  Int(arc4random_uniform(UInt32(range.endIndex + 1 - range.startIndex))) + range.startIndex
}