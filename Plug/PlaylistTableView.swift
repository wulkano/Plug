//
//  PlaylistTableView.swift
//  Plug
//
//  Created by Alex Marchant on 7/23/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PlaylistTableView: NSTableView {
    var trackingArea: NSTrackingArea?
    var previousMouseOverRow: Int = -1
    var viewController: PlaylistTableViewViewController!
    var count: Int = 0
    
    init(coder: NSCoder!) {
        super.init(coder: coder)
        trackScrolling()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func trackScrolling() {
        let clipView = superview as NSClipView
        clipView.postsBoundsChangedNotifications = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "mouseDidScroll", name: NSViewBoundsDidChangeNotification, object: clipView)
        
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        ensureTrackingArea()
        if !trackingAreas.bridgeToObjectiveC().containsObject(trackingArea) {
            addTrackingArea(trackingArea)
        }
    }
    
    func ensureTrackingArea() {
        if !trackingArea {
            trackingArea = NSTrackingArea(rect: NSZeroRect, options: NSTrackingAreaOptions.InVisibleRect | NSTrackingAreaOptions.ActiveAlways | NSTrackingAreaOptions.MouseEnteredAndExited | NSTrackingAreaOptions.MouseMoved, owner: self, userInfo: nil)
        }
    }
    
    override func mouseMoved(theEvent: NSEvent!) {
        super.mouseMoved(theEvent)
        
        let point = convertPoint(theEvent.locationInWindow, fromView: window.contentView as NSView)
        let row = rowAtPoint(point)
        if row != previousMouseOverRow {
            viewController.mouseOverTableViewRow(row)
            previousMouseOverRow = row
        }
    }
    
    override func mouseExited(theEvent: NSEvent!) {
        super.mouseExited(theEvent)
        
        viewController.mouseExitedTableView()
        previousMouseOverRow = -1
    }
    
    func mouseDidScroll() {
        viewController.mouseDidScrollTableView()
    }
}

protocol PlaylistTableViewViewController {
    func mouseOverTableViewRow(row: Int)
    func mouseExitedTableView()
    func mouseDidScrollTableView()
}