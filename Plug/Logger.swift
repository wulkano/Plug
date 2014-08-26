//
//  Logger.swift
//  Plug
//
//  Created by Alex Marchant on 8/25/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Foundation

struct Logger {
    static func LogError(error: NSError) {
        println("Error: \(error)")
    }
}