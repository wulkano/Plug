//
//  Swignal3Args.swift
//  Plug
//
//  Created by Joseph Neuman on 7/3/16.
//  Copyright © 2016 Plug. All rights reserved.
//

import Foundation

open class Swignal3Args<A,B,C>: SwignalBase {
    
    public override init() {
    }
    
    open func addObserver<L: AnyObject>(_ observer: L, callback: @escaping (_ observer: L, _ arg1: A, _ arg2: B, _ arg3: C) -> ()) {
        let observer = Observer3Args(swignal: self, observer: observer, callback: callback)
        addSwignalObserver(observer)
    }
    
    open func fire(_ arg1: A, arg2: B, arg3: C) {
        synced(self) {
            for watcher in self.swignalObservers {
                watcher.fire(arg1, arg2, arg3)
            }
        }
    }
}

private class Observer3Args<L: AnyObject,A,B,C>: ObserverGenericBase<L> {
    let callback: (_ observer: L, _ arg1: A, _ arg2: B, _ arg3: C) -> ()
    
    init(swignal: SwignalBase, observer: L, callback: @escaping (_ observer: L, _ arg1: A, _ arg2: B, _ arg3: C) -> ()) {
        self.callback = callback
        super.init(swignal: swignal, observer: observer)
    }
    
    override func fire(_ args: Any...) {
        if let arg1 = args[0] as? A,
            let arg2 = args[1] as? B,
            let arg3 = args[2] as? C {
            fire(arg1: arg1, arg2: arg2, arg3: arg3)
        } else {
            assert(false, "Types incorrect")
        }
    }
    
    fileprivate func fire(arg1: A, arg2: B, arg3: C) {
        if let observer = observer {
            callback(observer, arg1, arg2, arg3)
        }
    }
}
