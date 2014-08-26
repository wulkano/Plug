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
    
    static let DisplayError = "Plug.DisplayErrorNotification"
    
    static let NavigationSectionChanged = "Plug.NavigationSectionChangedNotification"

    
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
        
        static func DisplayError(error: NSError, sender: AnyObject?) {
            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.DisplayError, object: sender, userInfo: ["error": error])
        }
    }
    
    struct Subscribe {
        static func TrackPlaying(subscriber: AnyObject, selector: Selector, object: AnyObject? = nil) {
            NSNotificationCenter.defaultCenter().addObserver(subscriber, selector: selector, name: Notifications.TrackPlaying, object: object)
        }
        
        static func TrackPaused(subscriber: AnyObject, selector: Selector, object: AnyObject? = nil) {
            NSNotificationCenter.defaultCenter().addObserver(subscriber, selector: selector, name: Notifications.TrackPlaying, object: object)
        }
        
        static func TrackLoved(subscriber: AnyObject, selector: Selector, object: AnyObject? = nil) {
            NSNotificationCenter.defaultCenter().addObserver(subscriber, selector: selector, name: Notifications.TrackPlaying, object: object)
        }
        
        static func TrackUnLoved(subscriber: AnyObject, selector: Selector, object: AnyObject? = nil) {
            NSNotificationCenter.defaultCenter().addObserver(subscriber, selector: selector, name: Notifications.TrackPlaying, object: object)
        }
        
        static func TrackProgressUpdated(subscriber: AnyObject, selector: Selector, object: AnyObject? = nil) {
            NSNotificationCenter.defaultCenter().addObserver(subscriber, selector: selector, name: Notifications.TrackPlaying, object: object)
        }
        
        static func DisplayError(subscriber: AnyObject, selector: Selector, object: AnyObject? = nil) {
            NSNotificationCenter.defaultCenter().addObserver(subscriber, selector: selector, name: Notifications.DisplayError, object: object)
        }
    }
    
    static func UnsubscribeAll(subscriber: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(subscriber)
    }
    
    struct Read {
        static func TrackNotification(notification: NSNotification) -> Track {
            return notification.userInfo!["track"] as Track
        }
        
        static func TrackProgressNotification(notification: NSNotification) -> (track: Track, progress: Double, duration: Double) {
            let track = notification.userInfo!["track"] as Track
            let progress = (notification.userInfo!["progress"] as NSNumber).doubleValue
            let duration = (notification.userInfo!["duration"] as NSNumber).doubleValue
            return (track, progress, duration)
        }
        
        static func ErrorNotification(notification: NSNotification) -> NSError {
            return notification.userInfo!["error"] as NSError
        }
    }
}