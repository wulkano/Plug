//
//	Async.swift
//	Plug
//
//	Created by Alex Marchant on 6/21/14.
//	Copyright (c) 2014 Alex Marchant. All rights reserved.
//

import Foundation

class Async {
	class func lowPriority(_ closure: @escaping () -> Void) {
		let queue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.low)
		queue.async {
			closure()
		}
	}

	class func defaultPriority(_ closure: @escaping () -> Void) {
		let queue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
		queue.async {
			closure()
		}
	}

	class func highPriority(_ closure: @escaping () -> Void) {
		let queue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high)
		queue.async {
			closure()
		}
	}

	class func mainQueue(_ closure: @escaping () -> Void) {
		let queue = DispatchQueue.main
		queue.async {
			closure()
		}
	}
}
