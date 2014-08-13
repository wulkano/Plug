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
    var priority: Bool = false
    
    init(JSON json: NSDictionary) {
        name = (json["tag_name"] as String).capitalizedString
        
        if json["priority"] is Bool {
            priority = json["priority"] as Bool
        }
        
        super.init()
    }
}
