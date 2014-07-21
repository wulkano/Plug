//
//  PlaylistTableCellView.swift
//  Plug
//
//  Created by Alexander Marchant on 7/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PlaylistTableCellView: NSTableCellView {
    override var backgroundStyle: NSBackgroundStyle {
        get { return NSBackgroundStyle.Light }
        set {}
    }
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