//
//  Notifications.swift
//  Plug
//
//  Created by Alex Marchant on 8/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

struct Notifications {
    static let TrackPlaying = "Plug.TrackPlayingNotification"
    static let TrackPaused = "Plug.TrackPausedNotification"
    static let TrackLoved = "Plug.TrackLovedNotification"
    static let TrackUnLoved = "Plug.TrackUnLovedNotification"
    static let TrackProgressUpdated = "Plug.TrackProgressUpdatedNotification"
    static let NavigationSectionChanged = "Plug.NavigationSectionChangedNotification"
    static let Error = "Plug.ErrorNotification"
    
    struct Post {
        static func TrackPlaying(track: Track, sender: AnyObject?) {
            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.TrackPlaying, object: sender, userInfo: ["track": track])
        }
        
        static func TrackPaused(track: Track, sender: AnyObject?) {
            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.TrackPaused, object: sender, userInfo: ["track": track])
        }
        
        static func TrackLoved(track: Track, sender: AnyObject?) {
            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.TrackLoved, object: sender, userInfo: ["track": track])
        }
        
        static func TrackUnLoved(track: Track, sender: AnyObject?) {
            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.TrackUnLoved, object: sender, userInfo: ["track": track])
        }
        
        static func TrackProgressUpdated(track: Track, progress: Double, duration: Double, sender: AnyObject?) {
            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.TrackProgressUpdated, object: sender, userInfo: ["track": track, "progress": progress, "duration": duration])
        }
    }
}