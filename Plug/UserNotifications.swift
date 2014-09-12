//
//  UserNotifications.swift
//  Plug
//
//  Created by Alex Marchant on 8/31/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Foundation

struct UserNotifications {
    struct Deliver {
        static func NewTrackPlaying(track: Track) {
            deliverNotification(track.title, informativeText: track.artist)
        }
        
        static func SimpleText(text: String) {
            deliverNotification(text, informativeText: nil)
        }
        
        private static func deliverNotification(title: String, informativeText: String?) {
            if NSUserDefaults.standardUserDefaults().valueForKey(ShowTrackChangeNotificationsKey) as Bool {
                var notification = NSUserNotification()
                notification.title = title
                notification.informativeText = informativeText
                notification.soundName = nil
                
                NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
            }
        }
    }
}