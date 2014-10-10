//
//  Dictionary+merge.swift
//  Alex Marchant
//
//  Created by Alex Marchant on 10/10/14.
//  Copyright (c) 2014 Alex Marchant. All rights reserved.
//

import Foundation

extension Dictionary /* <KeyType, ValueType> */ {
    func merge(dictionary: Dictionary<Key, Value>) -> Dictionary {
        var newDictionary = self
        for key in dictionary.keys {
            if newDictionary[key] != nil { continue }
            newDictionary[key] = dictionary[key]
        }
        return newDictionary
    }
}