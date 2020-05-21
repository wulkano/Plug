import Cocoa

final class UserNotificationHandler: NSObject, NSUserNotificationCenterDelegate {
	static let shared = UserNotificationHandler()

	override init() {
		super.init()

		initialSetup()
	}

	func initialSetup() {
		NSUserNotificationCenter.default.delegate = self
	}

	func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool { true }
}
