//
//  Array+contains.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Foundation

extension Array {
    func contains(str: String) -> Bool {
        for obj in self {
            if obj as! String == str {
                return true
            }
        }
        return false
    }
}