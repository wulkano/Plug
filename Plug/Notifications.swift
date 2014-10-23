//
//  Notifications.swift
//  Plug
//
//  Created by Alex Marchant on 8/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

struct Notifications {
    static let CurrentTrackDidShow = "Plug.CurrentTrackDidShow"
    static let CurrentTrackDidHide = "Plug.CurrentTrackDidHide"
    static let DisplayError = "Plug.DisplayErrorNotification"
    static let NavigationSectionChanged = "Plug.NavigationSectionChangedNotification"
    static let PushViewController = "Plug.PushViewController"
    static let TrackLoved = "Plug.TrackLovedNotification"
    static let TrackUnLoved = "Plug.TrackUnLovedNotification"
    static let TrackPaused = "Plug.TrackPausedNotification"
    static let TrackPlaying = "Plug.TrackPlayingNotification"
    static let TrackProgressUpdated = "Plug.TrackProgressUpdatedNotification"
    static let RefreshCurrentView = "Plug.RefreshCurrentView"

    static func post(#name: String, object: AnyObject!, userInfo: [NSObject: AnyObject]!) {
        NSNotificationCenter.defaultCenter().postNotificationName(name, object: object, userInfo: userInfo)
    }
    
    static func subscribe(#observer: AnyObject!, selector: Selector, name: String!, object: AnyObject!) {
        NSNotificationCenter.defaultCenter().addObserver(observer, selector: selector, name: name, object: object)
    }
    
    static func unsubscribe(#observer: AnyObject!, name: String!, object: AnyObject!) {
        NSNotificationCenter.defaultCenter().removeObserver(observer, name: name, object: object)
    }
    
    static func unsubscribeAll(#observer: AnyObject!) {
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }
}