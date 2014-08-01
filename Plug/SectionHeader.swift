//
//  SectionHeader.swift
//  Plug
//
//  Created by Alex Marchant on 7/31/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class SectionHeader: NSObject {
    var title: String
    
    init(title: String) {
        self.title = title
        super.init()
    }
}
