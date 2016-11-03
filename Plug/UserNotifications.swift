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
    static func deliverNotification(title: String, informativeText: String?) {
        if UserDefaults.standard.value(forKey: ShowTrackChangeNotificationsKey) as! Bool {
            let notification = NSUserNotification()
            notification.title = title
            notification.informativeText = informativeText
            notification.soundName = nil
            
            NSUserNotificationCenter.default.deliver(notification)
        }
    }
}
