import Foundation

public final class Swignal0Args: SwignalBase {
	override public init() {}

	public func addObserver<L: AnyObject>(_ observer: L, callback: @escaping (_ observer: L) -> Void) {
		let observer = Observer0Args(swignal: self, observer: observer, callback: callback)
		addSwignalObserver(observer)
	}

	public func fire() {
		synced(self) {
			for watcher in self.swignalObservers {
				watcher.fire()
			}
		}
	}
}

private final class Observer0Args<L: AnyObject>: ObserverGenericBase<L> {
	let callback: ((_ observer: L) -> Void)?

	init(swignal: SwignalBase, observer: L, callback: @escaping (_ observer: L) -> Void) {
		self.callback = callback
		super.init(swignal: swignal, observer: observer)
	}

	override func fire(_ args: Any...) {
		if let observer = observer {
			callback?(observer)
		}
	}
}
