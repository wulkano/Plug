import Foundation
import HypeMachineAPI

struct UserNotifications {
	static func deliverNotification(title: String, informativeText: String?) {
		if UserDefaults.standard.bool(forKey: ShowTrackChangeNotificationsKey) {
			let notification = NSUserNotification()
			notification.title = title
			notification.informativeText = informativeText
			notification.soundName = nil

			NSUserNotificationCenter.default.deliver(notification)
		}
	}
}
