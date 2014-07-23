//
//  HoverTableCellView.swift
//  Plug
//
//  Created by Alex Marchant on 7/23/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class HoverTableCellView: NSTableCellView {
    var trackingArea: NSTrackingArea?
    var mouseInside: Bool = false

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        ensureTrackingArea()
        if !trackingAreas.bridgeToObjectiveC().containsObject(trackingArea) {
            addTrackingArea(trackingArea)
        }
    }
    
    func ensureTrackingArea() {
        if !trackingArea {
            trackingArea = NSTrackingArea(rect: NSZeroRect, options: NSTrackingAreaOptions.InVisibleRect | NSTrackingAreaOptions.ActiveAlways | NSTrackingAreaOptions.MouseEnteredAndExited, owner: self, userInfo: nil)
        }
    }
    
    override func mouseEntered(theEvent: NSEvent!) {
        mouseInside = true
        super.mouseEntered(theEvent)
    }
    
    override func mouseExited(theEvent: NSEvent!) {
        mouseInside = false
        super.mouseExited(theEvent)
    }
}
