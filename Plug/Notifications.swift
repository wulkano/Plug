//
//	Notifications.swift
//	Plug
//
//	Created by Alex Marchant on 8/14/14.
//	Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

struct Notifications {
	static let DisplayError = Notification.Name("Plug.DisplayErrorNotification")

	static let NewCurrentTrack = Notification.Name("Plug.NewCurrentTrack")

	static let TrackLoved = Notification.Name("Plug.TrackLovedNotification")
	static let TrackUnLoved = Notification.Name("Plug.TrackUnLovedNotification")
	static let TrackPaused = Notification.Name("Plug.TrackPausedNotification")
	static let TrackPlaying = Notification.Name("Plug.TrackPlayingNotification")
	static let TrackProgressUpdated = Notification.Name("Plug.TrackProgressUpdatedNotification")

	static let RefreshCurrentView = Notification.Name("Plug.RefreshCurrentView")
}


extension Notifications {
	static func post(name: Notification.Name, object: AnyObject!, userInfo: [AnyHashable: Any]!) {
		NotificationCenter.default.post(name: name, object: object, userInfo: userInfo)
	}

	static func subscribe(observer: AnyObject!, selector: Selector, name: Notification.Name, object: AnyObject!) {
		NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: object)
	}

	static func unsubscribe(observer: AnyObject!, name: Notification.Name, object: AnyObject!) {
		NotificationCenter.default.removeObserver(observer, name: name, object: object)
	}

	static func unsubscribeAll(observer: AnyObject!) {
		NotificationCenter.default.removeObserver(observer)
	}
}
