import Foundation

final class Interval {
	let closure: () -> Void
	var timer: Timer!

	@discardableResult
	static func single(_ interval: Double, closure: @escaping () -> Void) -> Self {
		Self(interval: interval, closure: closure, repeats: false)
	}

	@discardableResult
	static func repeating(_ interval: Double, closure: @escaping () -> Void) -> Self {
		Self(interval: interval, closure: closure, repeats: true)
	}

	init(interval: Double, closure: @escaping () -> Void, repeats: Bool) {
		self.closure = closure
		self.timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(runClosure), userInfo: nil, repeats: repeats)
	}

	@objc
	func runClosure() {
		closure()
	}

	func invalidate() {
		timer.invalidate()
	}
}
