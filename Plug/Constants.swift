import Foundation
import Sentry

extension NSColor {
	static let borderColor = NSColor(named: "BorderColor")!
}

func recordNonFatalError(_ error: Error, userInfo: [String: Any] = [:]) {
	let nsError = NSError.from(error: error, userInfo: userInfo)
	SentrySDK.capture(error: nsError)
}
