//
//	Swignal2Args.swift
//	Plug
//
//	Created by Joseph Neuman on 7/3/16.
//	Copyright © 2016 Plug. All rights reserved.
//

import Foundation

public final class Swignal2Args<A, B>: SwignalBase {
	override public init() {}

	public func addObserver<L: AnyObject>(_ observer: L, callback: @escaping (_ observer: L, _ arg1: A, _ arg2: B) -> Void) {
		let observer = Observer2Args(swignal: self, observer: observer, callback: callback)
		addSwignalObserver(observer)
	}

	public func fire(_ arg1: A, arg2: B) {
		synced(self) {
			for watcher in self.swignalObservers {
				watcher.fire(arg1, arg2)
			}
		}
	}
}

private class Observer2Args<L: AnyObject, A, B>: ObserverGenericBase<L> {
	let callback: (_ observer: L, _ arg1: A, _ arg2: B) -> Void

	init(swignal: SwignalBase, observer: L, callback: @escaping (_ observer: L, _ arg1: A, _ arg2: B) -> Void) {
		self.callback = callback
		super.init(swignal: swignal, observer: observer)
	}

	override func fire(_ args: Any...) {
		if let arg1 = args[0] as? A,
			let arg2 = args[1] as? B {
			fire(arg1: arg1, arg2: arg2)
		} else {
			assert(false, "Types incorrect")
		}
	}

	fileprivate func fire(arg1: A, arg2: B) {
		if let observer = observer {
			callback(observer, arg1, arg2)
		}
	}
}
