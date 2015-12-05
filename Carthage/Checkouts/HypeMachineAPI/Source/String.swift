//
//  String.swift
//  HypeMachineAPI
//
//  Created by Alex Marchant on 7/15/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

extension String {
    func stringByAddingPercentEncodingForURLQueryValue() -> String? {
        let characterSet = NSMutableCharacterSet.alphanumericCharacterSet()
        characterSet.addCharactersInString("-._~:/")
        
        return stringByAddingPercentEncodingWithAllowedCharacters(characterSet)
    }
}