//
//  RegEx.swift
//  Plug
//
//  Created by Alex Marchant on 8/19/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Foundation

class Regex {
    let internalExpression: NSRegularExpression
    let pattern: String
    
    init(pattern: String) {
        self.pattern = pattern
        self.internalExpression = try! NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
    }
    
    func test(input: String) -> Bool {
        let matches = self.internalExpression.matchesInString(input, options: [], range:NSMakeRange(0, input.characters.count))
        return matches.count > 0
    }
}

infix operator =~ {}

func =~ (input: String, pattern: String) -> Bool {
    return Regex(pattern: pattern).test(input)
}