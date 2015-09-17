//
//  Analytics.swift
//  Plug
//
//  Created by Alex Marchant on 9/10/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import SimpleGoogleAnalytics

struct Analytics {
    static let sharedTracker = SimpleGoogleAnalytics.Manager(trackingID: "UA-54659511-1", appBundle: NSBundle.mainBundle(), userID: Authentication.GetUsernameHash())
    
    static func trackView(viewName: String) {
        sharedTracker.trackPageview(viewName)
    }
    
    static func trackEvent(category category: String, action: String, label: String?, value: String?) {
        sharedTracker.trackEvent(category: category, action: action, label: label, value: value)
    }
    
    static func trackButtonClick(buttonName: String) {
        trackEvent(category: "Button", action: "Click", label: buttonName, value: nil)
    }
    
    static func trackAudioPlaybackEvent(actionName: String) {
        trackEvent(category: "AudioPlayback", action: actionName, label: nil, value: nil)
    }
}
