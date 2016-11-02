//
//  Swignal2Args.swift
//  Plug
//
//  Created by Joseph Neuman on 7/3/16.
//  Copyright © 2016 Plug. All rights reserved.
//

import Foundation

open class Swignal2Args<A,B>: SwignalBase {
    
    public override init() {
    }
    
    open func addObserver<L: AnyObject>(_ observer: L, callback: @escaping (_ observer: L, _ arg1: A, _ arg2: B) -> ()) {
        let observer = Observer2Args(swignal: self, observer: observer, callback: callback)
        addSwignalObserver(observer)
    }
    
    open func fire(_ arg1: A, arg2: B) {
        synced(self) {
            for watcher in self.swignalObservers {
                watcher.fire(arg1, arg2)
            }
        }
    }
}

private class Observer2Args<L: AnyObject,A,B>: ObserverGenericBase<L> {
    let callback: (_ observer: L, _ arg1: A, _ arg2: B) -> ()
    
    init(swignal: SwignalBase, observer: L, callback: @escaping (_ observer: L, _ arg1: A, _ arg2: B) -> ()) {
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
