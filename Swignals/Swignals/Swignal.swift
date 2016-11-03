//
//  Swignal.swift
//  Plug
//
//  Created by Joseph Neuman on 7/2/16.
//  Copyright © 2016 Plug. All rights reserved.
//

import Foundation

open class SwignalBase {
    internal var swignalObservers: [ObserverBase] = []
    
    internal func addSwignalObserver(_ swignalObserver: ObserverBase) {
        purgeDeallocatedListeners()
        
        synced(self) {
            self.swignalObservers.append(swignalObserver)
        }
    }
    
    open func removeObserver(_ observer: AnyObject) {
        synced(self) {
            for swignalObserver in self.swignalObservers {
                if swignalObserver.genericObserver === observer {
                    self.swignalObservers.removeObject(swignalObserver)
                }
            }
        }
    }
    
    open func removeAllObservers() {
        synced(self) {
            self.swignalObservers.removeAll()
        }
    }
    
    fileprivate func purgeDeallocatedListeners() {
        synced(self) {
            for swignalObserver in self.swignalObservers {
                if swignalObserver.genericObserver == nil {
                    self.removeObserver(swignalObserver)
                }
            }
        }
    }
}

internal class ObserverBase: Equatable {
    let swignal: SwignalBase!
    weak var genericObserver: AnyObject?
    
    init(swignal: SwignalBase) {
        self.swignal = swignal
    }
    
    func fire(_ args: Any...) {
        assert(false, "This method must be overriden by the subclass")
    }
}

internal class ObserverGenericBase<L: AnyObject>: ObserverBase {
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

func ==(lhs: ObserverBase, rhs: ObserverBase) -> Bool {
    return lhs === rhs
}



// MARK: Helpers
internal func synced(_ lock: AnyObject, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

private extension Array {
    mutating func removeObject<T>(_ obj: T) where T : Equatable {
        self = self.filter({$0 as? T != obj})
    }
    
}
