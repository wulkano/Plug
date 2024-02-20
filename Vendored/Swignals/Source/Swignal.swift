import Foundation

public class SwignalBase {
	var swignalObservers = [ObserverBase]()

	func addSwignalObserver(_ swignalObserver: ObserverBase) {
		purgeDeallocatedListeners()

		synced(self) {
			swignalObservers.append(swignalObserver)
		}
	}

	public func removeObserver(_ observer: AnyObject) {
		synced(self) {
			for swignalObserver in swignalObservers where swignalObserver.genericObserver === observer {
				swignalObservers.removeObject(swignalObserver)
			}
		}
	}

	public func removeAllObservers() {
		synced(self) {
			swignalObservers.removeAll()
		}
	}

	private func purgeDeallocatedListeners() {
		synced(self) {
			for swignalObserver in swignalObservers where swignalObserver.genericObserver == nil {
				removeObserver(swignalObserver)
			}
		}
	}
}

class ObserverBase: Equatable { // swiftlint:disable:this final_class
	let swignal: SwignalBase!
	weak var genericObserver: AnyObject?

	init(swignal: SwignalBase) {
		self.swignal = swignal
	}

	func fire(_ args: Any...) {
		assertionFailure("This method must be overriden by the subclass")
	}
}

class ObserverGenericBase<L: AnyObject>: ObserverBase { // swiftlint:disable:this final_class
	weak var observer: L? {
		didSet {
			genericObserver = observer
		}
	}

	init(swignal: SwignalBase, observer: L) {
		defer {
			// This is defered so that the didSet is called. didSet is normally not called when a ar is set within an init.
			self.observer = observer
		}
		super.init(swignal: swignal)
	}
}

extension ObserverBase {
	static func == (lhs: ObserverBase, rhs: ObserverBase) -> Bool {
		lhs === rhs
	}
}



// MARK: Helpers
func synced(_ lock: AnyObject, closure: () -> Void) {
	objc_sync_enter(lock)
	closure()
	objc_sync_exit(lock)
}

extension Array {
	fileprivate mutating func removeObject<T>(_ obj: T) where T: Equatable {
		self = filter { $0 as? T != obj }
	}
}
