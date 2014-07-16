//
//  DictHelper.swift
//  Plug
//
//  Created by Alex Marchant on 7/6/14.
//  Copyright (c) 2014 Alex Marchant. All rights reserved.
//

import Foundation

struct DictHelper {
    
    static func stringValueOrPlaceholder(value: AnyObject?, placeholder: String) -> String {
        if value is String {
            return value as String
        } else {
            return placeholder
        }
    }
    
    static func stringValueOrNil(value: AnyObject?) -> String? {
        if value is String {
            return (value as String)
        } else {
            return nil
        }
    }
    
    static func integerValueOrPlaceholder(value: AnyObject?, placeholder: Int) -> Int {
        if value is Int {
            return value as Int
        } else {
            return placeholder
        }
    }
    
    static func integerValueOrNil(value: AnyObject?) -> Int? {
        if value is Int {
            return (value as Int)
        } else {
            return nil
        }
    }
    
    static func boolValueOrPlaceholder(value: AnyObject?, placeholder: Bool) -> Bool {
        if value is Bool {
            return value as Bool
        } else {
            return placeholder
        }
    }
    
    static func urlValueOrPlaceholder(value: AnyObject?, placeholder: String) -> NSURL {
        if value is String {
            return NSURL(string: value as String)
        } else {
            return NSURL(string: placeholder)
        }
    }
    
    static func urlValueOrNil(value: AnyObject?) -> NSURL? {
        if value is String {
            return NSURL(string: value as String)
        } else {
            return nil
        }
    }
}