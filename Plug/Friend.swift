//
//  Friend.swift
//  Plug
//
//  Created by Alex Marchant on 8/1/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class Friend: NSObject {
    var username: String
    var fullName: String
    
    init(JSON json: NSDictionary) {
        username = json["username"] as String
        if json["fullname"] is String {
            fullName = json["fullname"] as String
        } else {
            fullName = username
        }
        super.init()
    }
}
