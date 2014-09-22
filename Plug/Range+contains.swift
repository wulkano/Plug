//
//  Range+contains.swift
//  Plug
//
//  Created by Alex Marchant on 9/13/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Foundation

extension Range {
    func contains(thing: T) -> Bool {
        for obj in self {
            if obj == thing {
                return true
            }
        }
        return false
    }
}