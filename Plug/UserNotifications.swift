//
//  UserNotifications.swift
//  Plug
//
//  Created by Alex Marchant on 8/31/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Foundation
import HypeMachineAPI

struct UserNotifications {
    static func deliverNotification(title title: String, informativeText: String?) {
        if NSUserDefaults.standardUserDefaults().valueForKey(ShowTrackChangeNotificationsKey) as! Bool {
            let notification = NSUserNotification()
            notification.title = title
            notification.informativeText = informativeText
            notification.soundName = nil
            
            NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
        }
    }
}