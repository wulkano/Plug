//
//  Analytics.swift
//  Plug
//
//  Created by Alex Marchant on 9/10/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class Analytics {
    class var sharedInstance: Analytics {
        struct Singleton {
            static let instance = Analytics()
        }
        return Singleton.instance
    }
    
    let tracker = GoogleAnalytics(trackingID: "UA-54659511-1")
    
    func trackView(viewName: String) {
        tracker.trackPageview(viewName)
    }
    
    func trackButtonClick(buttonName: String) {
        trackEvent("Button", action: "Click", label: buttonName, value: nil)
    }
    
    func trackAudioPlaybackEvent(actionName: String) {
        trackEvent("AudioPlayback", action: actionName, label: nil, value: nil)
    }
    
    func trackEvent(category: String, action: String, label: String?, value: String?) {
        tracker.trackEvent(category, action: action, label: label, value: value)
    }
}
