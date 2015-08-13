//
//  FlatSlider.swift
//  Plug
//
//  Created by Alex Marchant on 8/18/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class FlatSlider: NSSlider {
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
    var flatSliderCell: FlatSliderCell {
        return cell() as! FlatSliderCell
    }
    var mouseDown: Bool {
        get { return flatSliderCell.mouseDown }
        set { flatSliderCell.mouseDown = newValue }
    }
    var mouseInside: Bool {
        get { return flatSliderCell.mouseInside }
        set { flatSliderCell.mouseInside = newValue }
    }
    
    override func viewDidMoveToWindow() {
        addTrackingRect(bounds, owner: self, userData: nil, assumeInside: false)
    }
    
    override func mouseDown(theEvent: NSEvent) {
        mouseDown = true
        mouseUp(theEvent)
    }
    
    override func mouseUp(theEvent: NSEvent) {
        mouseDown = false
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        mouseInside = true
        needsDisplay = true
    }
    
    override func mouseExited(theEvent: NSEvent) {
        mouseInside = false
        needsDisplay = true
    }
}
