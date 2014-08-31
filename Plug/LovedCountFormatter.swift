//
//  LoveCountFormatter.swift
//  Plug
//
//  Created by Alex Marchant on 8/28/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class LovedCountFormatter: NSFormatter {
    @IBInspectable var capitalize: Bool = false
    
    override func stringForObjectValue(obj: AnyObject) -> String? {
        var count = (obj as NSNumber).integerValue
        var returnString: String?
        
        if count >= 1000 {
            let numberFormatter = NSNumberFormatter()
            numberFormatter.format = "####k"
            let abbrLovedCount = Double(count) / 1000
            returnString = numberFormatter.stringFromNumber(abbrLovedCount)
        } else {
            returnString = "\(count)"
        }
        
        if capitalize {
            returnString = returnString!.uppercaseString
        }
        
        return returnString
    }
}
