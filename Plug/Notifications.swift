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
    
    static let PushViewController = "Plug.PushViewController"
    
    static let CurrentTrackDidShow = "Plug.CurrentTrackDidShow"
    static let CurrentTrackDidHide = "Plug.CurrentTrackDidHide"

    
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
        
        static func NavigationSectionChanged(section: NavigationSection, sender: AnyObject?) {
            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.NavigationSectionChanged, object: sender, userInfo: ["navigationSection": section.toRaw()])
        }
        
        static func PushViewController(viewController: BaseContentViewController, sender: AnyObject?) {
            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.PushViewController, object: sender, userInfo: ["viewController": viewController])
        }
        
        static func CurrentTrackDidShow(sender: AnyObject?) {
            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.CurrentTrackDidShow, object: sender)
        }
        
        static func CurrentTrackDidHide(sender: AnyObject?) {
            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.CurrentTrackDidHide, object: sender)
        }
    }
    
    struct Subscribe {
        static func TrackPlaying(subscriber: AnyObject, selector: Selector) {
            NSNotificationCenter.defaultCenter().addObserver(subscriber, selector: selector, name: Notifications.TrackPlaying, object: nil)
        }
        
        static func TrackPaused(subscriber: AnyObject, selector: Selector) {
            NSNotificationCenter.defaultCenter().addObserver(subscriber, selector: selector, name: Notifications.TrackPaused, object: nil)
        }
        
        static func TrackLoved(subscriber: AnyObject, selector: Selector) {
            NSNotificationCenter.defaultCenter().addObserver(subscriber, selector: selector, name: Notifications.TrackLoved, object: nil)
        }
        
        static func TrackUnLoved(subscriber: AnyObject, selector: Selector) {
            NSNotificationCenter.defaultCenter().addObserver(subscriber, selector: selector, name: Notifications.TrackUnLoved, object: nil)
        }
        
        static func TrackProgressUpdated(subscriber: AnyObject, selector: Selector) {
            NSNotificationCenter.defaultCenter().addObserver(subscriber, selector: selector, name: Notifications.TrackProgressUpdated, object: nil)
        }
        
        static func DisplayError(subscriber: AnyObject, selector: Selector) {
            NSNotificationCenter.defaultCenter().addObserver(subscriber, selector: selector, name: Notifications.DisplayError, object: nil)
        }
        
        static func NavigationSectionChanged(subscriber: AnyObject, selector: Selector) {
            NSNotificationCenter.defaultCenter().addObserver(subscriber, selector: selector, name: Notifications.NavigationSectionChanged, object: nil)
        }
        
        static func PushViewController(subscriber: AnyObject, selector: Selector) {
            NSNotificationCenter.defaultCenter().addObserver(subscriber, selector: selector, name: Notifications.PushViewController, object: nil)
        }
        
        static func CurrentTrackDidShow(subscriber: AnyObject, selector: Selector) {
            NSNotificationCenter.defaultCenter().addObserver(subscriber, selector: selector, name: Notifications.CurrentTrackDidShow, object: nil)
        }
        
        static func CurrentTrackDidHide(subscriber: AnyObject, selector: Selector) {
            NSNotificationCenter.defaultCenter().addObserver(subscriber, selector: selector, name: Notifications.CurrentTrackDidHide, object: nil)
        }
    }
    
    struct Unsubscribe {
        static func All(subscriber: AnyObject) {
            NSNotificationCenter.defaultCenter().removeObserver(subscriber)
        }
        
        static func TrackProgressUpdated(subscriber: AnyObject) {
            NSNotificationCenter.defaultCenter().removeObserver(subscriber, name: Notifications.TrackProgressUpdated, object: nil)
        }
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

        static func NavigationSectionNotification(notification: NSNotification) -> NavigationSection {
            let number = notification.userInfo!["navigationSection"] as NSNumber
            let raw = number.integerValue
            return NavigationSection.fromRaw(raw)!
        }
        
        static func PushViewControllerNotification(notification: NSNotification) -> BaseContentViewController {
            return notification.userInfo!["viewController"] as BaseContentViewController
        }
    }
}