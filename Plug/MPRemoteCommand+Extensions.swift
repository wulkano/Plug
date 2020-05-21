import Foundation
import MediaPlayer

extension MPRemoteCommand {
	// Convenience function to simplify the activation of the TouchBar button (aka MPRemoteCommand object).
	func activate(_ target: Any, action: Selector) {
		isEnabled = true
		addTarget(target, action: action)
	}
}
