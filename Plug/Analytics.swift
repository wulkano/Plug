//
//	Analytics.swift
//	Plug
//
//	Created by Alex Marchant on 9/10/14.
//	Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

struct Analytics {
	static let sharedTracker = Manager(trackingID: "UA-42119014-6", appBundle: Bundle.main, userID: Authentication.getUsernameHash())

	static func trackView(_ viewName: String) {
		sharedTracker.trackPageview(viewName)
	}

	static func trackEvent(category: String, action: String, label: String?, value: String?) {
		sharedTracker.trackEvent(category: category, action: action, label: label, value: value)
	}

	static func trackButtonClick(_ buttonName: String) {
		trackEvent(category: "Button", action: "Click", label: buttonName, value: nil)
	}

	static func trackAudioPlaybackEvent(_ actionName: String) {
		trackEvent(category: "AudioPlayback", action: actionName, label: nil, value: nil)
	}
}
