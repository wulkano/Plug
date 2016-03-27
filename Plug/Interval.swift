//
//  Interval.swift
//  Plug
//
//  Created by Alex Marchant on 6/23/14.
//  Copyright (c) 2014 Alex Marchant. All rights reserved.
//

import Foundation

class Interval : NSObject {
    var closure: ()->()
    var timer: NSTimer!
    
    class func single(interval: Double, closure: ()->()) -> Interval {
        return Interval(interval: interval, closure: closure, repeats: false)
    }
    
    class func repeating(interval: Double, closure: ()->()) -> Interval {
        return Interval(interval: interval, closure: closure, repeats: true)
    }
    
    init(interval: Double, closure: ()->(), repeats: Bool) {
        self.closure = closure
        super.init()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: #selector(runClosure), userInfo: nil, repeats: repeats)
    }
    
    func runClosure() {
        closure()
    }
    
    func invalidate() {
        timer.invalidate()
    }
}