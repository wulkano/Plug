import Foundation

public final class Swignal3Args<A, B, C>: SwignalBase {
	override public init() {}

	public func addObserver<L: AnyObject>(_ observer: L, callback: @escaping (_ observer: L, _ arg1: A, _ arg2: B, _ arg3: C) -> Void) {
		let observer = Observer3Args(swignal: self, observer: observer, callback: callback)
		addSwignalObserver(observer)
	}

	public func fire(_ arg1: A, arg2: B, arg3: C) {
		synced(self) {
			for watcher in swignalObservers {
				watcher.fire(arg1, arg2, arg3)
			}
		}
	}
}

private class Observer3Args<L: AnyObject, A, B, C>: ObserverGenericBase<L> {
	let callback: (_ observer: L, _ arg1: A, _ arg2: B, _ arg3: C) -> Void

	init(swignal: SwignalBase, observer: L, callback: @escaping (_ observer: L, _ arg1: A, _ arg2: B, _ arg3: C) -> Void) {
		self.callback = callback
		super.init(swignal: swignal, observer: observer)
	}

	override func fire(_ args: Any...) {
		if
			let arg1 = args[0] as? A,
			let arg2 = args[1] as? B,
			let arg3 = args[2] as? C
		{
			fire(arg1: arg1, arg2: arg2, arg3: arg3)
		} else {
			assertionFailure("Types incorrect")
		}
	}

	fileprivate func fire(arg1: A, arg2: B, arg3: C) {
		if let observer = observer {
			callback(observer, arg1, arg2, arg3)
		}
	}
}
