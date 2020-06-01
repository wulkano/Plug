import Foundation

final class Interval: NSObject {
	var closure: () -> Void
	var timer: Timer!

	static func single(_ interval: Double, closure: @escaping () -> Void) -> Interval {
		Interval(interval: interval, closure: closure, repeats: false)
	}

	static func repeating(_ interval: Double, closure: @escaping () -> Void) -> Interval {
		Interval(interval: interval, closure: closure, repeats: true)
	}

	init(interval: Double, closure: @escaping () -> Void, repeats: Bool) {
		self.closure = closure
		super.init()
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
