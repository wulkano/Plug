//
//  Notifications.swift
//  Plug
//
//  Created by Alex Marchant on 8/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

struct Notifications {
    static let DisplayError = "Plug.DisplayErrorNotification"

    static let NewCurrentTrack = "Plug.NewCurrentTrack"
    
    static let TrackLoved = "Plug.TrackLovedNotification"
    static let TrackUnLoved = "Plug.TrackUnLovedNotification"
    static let TrackPaused = "Plug.TrackPausedNotification"
    static let TrackPlaying = "Plug.TrackPlayingNotification"
    static let TrackProgressUpdated = "Plug.TrackProgressUpdatedNotification"
    
    static let RefreshCurrentView = "Plug.RefreshCurrentView"

    static func post(name: String, object: AnyObject!, userInfo: [AnyHashable: Any]!) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: object, userInfo: userInfo)
    }
    
    static func subscribe(observer: AnyObject!, selector: Selector, name: String!, object: AnyObject!) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: name.map { NSNotification.Name(rawValue: $0) }, object: object)
    }
    
    static func unsubscribe(observer: AnyObject!, name: String!, object: AnyObject!) {
        NotificationCenter.default.removeObserver(observer, name: name.map { NSNotification.Name(rawValue: $0) }, object: object)
    }
    
    static func unsubscribeAll(observer: AnyObject!) {
        NotificationCenter.default.removeObserver(observer)
    }
}
