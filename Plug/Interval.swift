//
//	Interval.swift
//	Plug
//
//	Created by Alex Marchant on 6/23/14.
//	Copyright (c) 2014 Alex Marchant. All rights reserved.
//

import Foundation

class Interval: NSObject {
	var closure: () -> Void
	var timer: Timer!

	class func single(_ interval: Double, closure: @escaping () -> Void) -> Interval {
		Interval(interval: interval, closure: closure, repeats: false)
	}

	class func repeating(_ interval: Double, closure: @escaping () -> Void) -> Interval {
		Interval(interval: interval, closure: closure, repeats: true)
	}

	init(interval: Double, closure: @escaping () -> Void, repeats: Bool) {
		self.closure = closure
		super.init()
		self.timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(runClosure), userInfo: nil, repeats: repeats)
	}

	@objc func runClosure() {
		closure()
	}

	func invalidate() {
		timer.invalidate()
	}
}
