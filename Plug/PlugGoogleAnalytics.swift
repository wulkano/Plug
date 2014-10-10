//
//  PlugGoogleAnalytics.swift
//  Plug
//
//  Created by Alex Marchant on 10/10/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PlugGoogleAnalytics: SimpleGoogleAnalytics {
    override func userID() -> String? {
        return Authentication.GetUsernameHash()
    }
}