//
//  String.swift
//  Plug
//
//  Created by Alex Marchant on 9/7/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

extension String {
    func getSubstringBetweenPrefix(prefix: String, andSuffix suffix: String) -> String? {
        
        func getSubstringAfterPrefix() -> String? {
            if let prefixRange = self.rangeOfString(prefix) {
                var substringRange = prefixRange.endIndex..<self.endIndex
                return self.substringWithRange(substringRange)
            } else {
                return nil
            }
        }
        
        func getSubstringBeforeSuffix(substring: String) -> String? {
            if let suffixRange = substring.rangeOfString(suffix) {
                var substringRange = substring.startIndex..<suffixRange.startIndex
                return substring.substringWithRange(substringRange)
            } else {
                return nil
            }
        }
        
        if let substringWithoutPrefix = getSubstringAfterPrefix() {
            substringWithoutPrefix
            return getSubstringBeforeSuffix(substringWithoutPrefix)
        } else {
            return nil
        }
        
    }
}