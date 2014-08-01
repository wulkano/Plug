//
//  Genre.swift
//  Plug
//
//  Created by Alex Marchant on 8/1/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class Genre: NSObject {
    var name: String
    var priority: Bool
    
    init(name: String, priority: Bool) {
        self.name = name
        self.priority = priority
        super.init()
    }
}
