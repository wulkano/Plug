//
//  Async.swift
//  Plug
//
//  Created by Alex Marchant on 6/21/14.
//  Copyright (c) 2014 Alex Marchant. All rights reserved.
//

import Foundation

class Async {
    class func LowPriority(_ closure: @escaping ()->()) {
        let queue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.low)
        queue.async(execute: {
            closure()
        })
    }
    
    class func DefaultPriority(_ closure: @escaping ()->()) {
        let queue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
        queue.async(execute: {
            closure()
        })
    }
    
    class func HighPriority(_ closure: @escaping ()->()) {
        let queue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high)
        queue.async(execute: {
            closure()
        })
    }
    
    class func MainQueue(_ closure: @escaping ()->()) {
        let queue = DispatchQueue.main
        queue.async(execute: {
            closure()
        })
    }
}
