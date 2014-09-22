//
//  EventHit.swift
//  Plug
//
//  Created by Alex Marchant on 9/11/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Foundation

struct EventHit: Hit {
    var category: String
    var action: String
    var label: String?
    var value: String?
    
    init(category: String, action: String, label: String?, value: String?) {
        self.category = category
        self.action = action
        self.label = label
        self.value = value
    }
    
    func description() -> String {
        return "<EventHit category: \(category), action: \(action), label: \(label), value: \(value)>"
    }
    
    func params() -> [String: String] {
        var params = [String: String]()
        params["t"] = "event"
        params["ec"] = category
        params["ea"] = action
        if label != nil {
            params["el"] = label
        }
        if value != nil {
            params["ev"] = value
        }
        return params
    }
}