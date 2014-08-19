//
//  FlatSlider.swift
//  Plug
//
//  Created by Alex Marchant on 8/18/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class FlatSlider: NSSlider {
    var mouseDown: Bool = false
    override var doubleValue: Double {
        get {
            return super.doubleValue
        }
        set {
            if !mouseDown {
                super.doubleValue = newValue
            }
        }
    }
    
    override func mouseDown(theEvent: NSEvent!) {
        mouseDown = true
        super.mouseDown(theEvent)
        mouseUp(theEvent)
    }
    
    override func mouseUp(theEvent: NSEvent!) {
        mouseDown = false
        super.mouseUp(theEvent)
    }
}
