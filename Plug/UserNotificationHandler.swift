//
//  UserNotificationHandler.swift
//  Plug
//
//  Created by Alex Marchant on 9/25/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class UserNotificationHandler: NSObject, NSUserNotificationCenterDelegate {
    class var sharedInstance: UserNotificationHandler {
        struct Singleton {
            static let instance = UserNotificationHandler()
        }
        return Singleton.instance
    }
    
    override init() {
        super.init()
        
        initialSetup()
    }
    
    func initialSetup() {
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification!) -> Bool {
        return true
    }
}
