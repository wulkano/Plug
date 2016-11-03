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
        return cell as! FlatSliderCell
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
    
    override func mouseDown(with theEvent: NSEvent) {
        mouseDown = true
        super.mouseDown(with: theEvent)
        mouseUp(with: theEvent)
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        mouseDown = false
        super.mouseUp(with: theEvent)
    }
    
    override func mouseEntered(with theEvent: NSEvent) {
        mouseInside = true
        needsDisplay = true
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        mouseInside = false
        needsDisplay = true
    }
}
