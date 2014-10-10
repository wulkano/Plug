//
//  ScreenviewHit.swift
//  Alex Marchant
//
//  Created by Alex Marchant on 10/10/14.
//  Copyright (c) 2014 Alex Marchant. All rights reserved.
//

import Foundation

struct ScreenviewHit: Hit {
    var viewName: String
    var contentDescription: String {
        return viewName
    }
    
    init(viewName: String) {
        self.viewName = viewName
    }
    
    func description() -> String {
        return "<ScreenviewHit viewName: \(viewName)>"
    }
    
    func params() -> [String: String] {
        return [
            "t": "screenview",
            "cd": contentDescription,
        ]
    }
}