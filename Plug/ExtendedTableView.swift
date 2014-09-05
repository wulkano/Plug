//
//  ExtendedTableView.swift
//  Plug
//
//  Created by Alex Marchant on 9/5/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class ExtendedTableView: NSTableView {
    @IBInspectable var tracksMouseEnterExit: Bool = false
    @IBInspectable var tracksMouseDidScroll: Bool = false
    
    var trackingArea: NSTrackingArea?
    var extendedDelegate: ExtendedTableViewDelegate?
    var mouseInsideRow: Int = -1
    
    deinit {
        Notifications.Unsubscribe.All(self)
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if tracksMouseEnterExit {
            ensureTrackingArea()
            if find(trackingAreas as [NSTrackingArea], trackingArea!) == nil {
                addTrackingArea(trackingArea!)
            }
        }
    }
    
    func ensureTrackingArea() {
        if trackingArea == nil {
            trackingArea = NSTrackingArea(rect: NSZeroRect, options: NSTrackingAreaOptions.InVisibleRect | NSTrackingAreaOptions.ActiveAlways | NSTrackingAreaOptions.MouseEnteredAndExited | NSTrackingAreaOptions.MouseMoved, owner: self, userInfo: nil)
        }
    }
    
    override func viewDidMoveToWindow() {
        if tracksMouseDidScroll {
            let clipView = superview as NSClipView
            clipView.postsBoundsChangedNotifications = true
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "mouseDidScroll", name: NSViewBoundsDidChangeNotification, object: clipView)
        }
    }

    override func mouseDown(theEvent: NSEvent!) {
        let globalLocation = theEvent.locationInWindow
        let localLocation = convertPoint(globalLocation, fromView: nil)
        let clickedRow = rowAtPoint(localLocation)
        
        super.mouseDown(theEvent)
        
        if clickedRow != -1 {
            extendedDelegate?.tableView?(self, didClickRow: clickedRow)
        }
    }
    
    override func mouseMoved(theEvent: NSEvent!) {
        super.mouseMoved(theEvent)
        
        let globalLocation = theEvent.locationInWindow
        let localLocation = convertPoint(globalLocation, fromView: nil)
        let newMouseInsideRow = rowAtPoint(localLocation)
        
        if newMouseInsideRow != mouseInsideRow {
            extendedDelegate?.tableView?(self, mouseEnteredRow: newMouseInsideRow)
            if mouseInsideRow != -1 {
                extendedDelegate?.tableView?(self, mouseExitedRow: mouseInsideRow)
            }
            mouseInsideRow = newMouseInsideRow
        }
    }
    
    override func mouseExited(theEvent: NSEvent!) {
        super.mouseExited(theEvent)
        
        if mouseInsideRow != -1 {
            extendedDelegate?.tableView?(self, mouseExitedRow: mouseInsideRow)
        }
        mouseInsideRow = -1
    }
    
    func mouseDidScroll() {
        extendedDelegate?.mouseDidScrollTableView?(self)
    }
}

@objc protocol ExtendedTableViewDelegate {
    optional func tableView(tableView: NSTableView, didClickRow row: Int)
    optional func tableView(tableView: NSTableView, mouseEnteredRow row: Int)
    optional func tableView(tableView: NSTableView, mouseExitedRow row: Int)
    optional func mouseDidScrollTableView(tableView: NSTableView)
}
