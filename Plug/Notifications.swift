import Cocoa

enum Notifications {
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
	// swiftlint:disable:next discouraged_optional_collection
	static func post(name: Notification.Name, object: Any?, userInfo: [AnyHashable: Any]? = nil) {
		NotificationCenter.default.post(name: name, object: object, userInfo: userInfo)
	}

	static func subscribe(observer: Any, selector: Selector, name: Notification.Name, object: Any?) {
		NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: object)
	}

	static func unsubscribe(observer: Any, name: Notification.Name, object: Any?) {
		NotificationCenter.default.removeObserver(observer, name: name, object: object)
	}

	static func unsubscribeAll(observer: Any) {
		NotificationCenter.default.removeObserver(observer)
	}
}
