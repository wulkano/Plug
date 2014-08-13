//
//  Blog.swift
//  Plug
//
//  Created by Alex Marchant on 7/25/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class Blog: NSObject {
    var id: String = "0"
    var name: String = "N/A"
    var featured: Bool = false
    var following: Bool = false
    
    init(JSON json: NSDictionary) {
        super.init()
        
        if json["siteid"] is String {
            id = json["siteid"] as String
        }
        if json["sitename"] is String {
            name = json["sitename"] as String
        }
        if json["ts_featured"] is Int {
            featured = true
        }
        if json["ts_loved_me"] is Int {
            following = true
        }
    }
}
