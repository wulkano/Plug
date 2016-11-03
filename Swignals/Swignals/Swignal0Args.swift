//
//  Swignal0Args.swift
//  Plug
//
//  Created by Joseph Neuman on 7/3/16.
//  Copyright © 2016 Plug. All rights reserved.
//

import Foundation

open class Swignal0Args: SwignalBase {
    
    public override init() {
    }
    
    open func addObserver<L: AnyObject>(_ observer: L, callback: @escaping (_ observer: L) -> ()) {
        let observer = Observer0Args(swignal: self, observer: observer, callback: callback)
        addSwignalObserver(observer
        )
    }
    
    open func fire() {
        synced(self) {
            for watcher in self.swignalObservers {
                watcher.fire()
            }
        }
    }
}

private class Observer0Args<L: AnyObject>: ObserverGenericBase<L> {
    let callback: (_ observer: L) -> ()!
    
    init(swignal: SwignalBase, observer: L, callback: @escaping (_ observer: L) -> ()) {
        self.callback = callback
        super.init(swignal: swignal, observer: observer)
    }
    
    override func fire(_ args: Any...) {
        if let observer = observer {
            callback(observer)
        }
    }
}
