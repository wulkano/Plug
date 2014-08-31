//
//  Async.swift
//  Plug
//
//  Created by Alex Marchant on 6/21/14.
//  Copyright (c) 2014 Alex Marchant. All rights reserved.
//

import Foundation

class Async {
    class func LowPriority(closure: ()->()) {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)
        dispatch_async(queue, {
            closure()
        })
    }
    
    class func DefaultPriority(closure: ()->()) {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue, {
            closure()
        })
    }
    
    class func HighPriority(closure: ()->()) {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
        dispatch_async(queue, {
            closure()
        })
    }
    
    class func MainQueue(closure: ()->()) {
        let queue = dispatch_get_main_queue()
        dispatch_async(queue, {
            closure()
        })
    }
}