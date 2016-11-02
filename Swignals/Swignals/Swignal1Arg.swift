//
//  SwignalCallbackProtocols.swift
//  Plug
//
//  Created by Joseph Neuman on 7/2/16.
//  Copyright © 2016 Plug. All rights reserved.
//

import Foundation

open class Swignal1Arg<A>: SwignalBase {
    
    public override init() {
    }
    
    open func addObserver<L: AnyObject>(_ observer: L, callback: @escaping (_ observer: L, _ arg1: A) -> ()) {
        let observer = Observer1Args(swignal: self, observer: observer, callback: callback)
        addSwignalObserver(observer)
    }
    
    open func fire(_ arg1: A) {
        synced(self) {
            for watcher in self.swignalObservers {
                watcher.fire(arg1)
            }
        }
    }
}

private class Observer1Args<L: AnyObject,A>: ObserverGenericBase<L> {
    let callback: (_ observer: L, _ arg1: A) -> ()
    
    init(swignal: SwignalBase, observer: L, callback: @escaping (_ observer: L, _ arg1: A) -> ()) {
        self.callback = callback
        super.init(swignal: swignal, observer: observer)
    }
    
    override func fire(_ args: Any...) {
        if let arg1 = args[0] as? A {
            fire(arg1: arg1)
        } else {
            assert(false, "Types incorrect")
        }
    }
    
    fileprivate func fire(arg1: A) {
        if let observer = observer {
            callback(observer, arg1)
        }
    }
}
