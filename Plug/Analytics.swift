//
//  Analytics.swift
//  Plug
//
//  Created by Alex Marchant on 9/10/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class Analytics: NSObject {
    
    func sendView(screen: String) -> Bool {
        return false
    }
    
    func sendEventWithCategory(category: String, action: String, label: String, value: NSNumber) -> Bool {
        return false
    }
}
