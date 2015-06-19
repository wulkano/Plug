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
    @IBInspectable var pullToRefresh: Bool = false
    
    var trackingArea: NSTrackingArea?
    var extendedDelegate: ExtendedTableViewDelegate?
    var mouseInsideRow: Int = -1
    
    var clipView: NSClipView {
        return superview as! NSClipView
    }
    var scrollView: NSScrollView? {
        return clipView.superview as? NSScrollView
    }
    var visibleRows: [Int] = []
    
    deinit {
        Notifications.unsubscribeAll(observer: self)
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if tracksMouseEnterExit {
            ensureTrackingArea()
            if find(trackingAreas as! [NSTrackingArea], trackingArea!) == nil {
                addTrackingArea(trackingArea!)
            }
        }
    }
    
    func ensureTrackingArea() {
        if trackingArea == nil {
            trackingArea = NSTrackingArea(rect: NSZeroRect, options: .InVisibleRect | .ActiveAlways | .MouseEnteredAndExited | .MouseMoved | .AssumeInside, owner: self, userInfo: nil)
        }
    }
    
    override func viewDidMoveToWindow() {
        Notifications.subscribe(observer: self, selector: "scrollViewDidStartScrolling:", name: NSScrollViewWillStartLiveScrollNotification, object: scrollView)
        Notifications.subscribe(observer: self, selector: "scrollViewDidScroll:", name: NSScrollViewDidLiveScrollNotification, object: scrollView)
        Notifications.subscribe(observer: self, selector: "scrollViewDidEndScrolling:", name: NSScrollViewDidEndLiveScrollNotification, object: scrollView)

        resetTrackingArea()
        mouseEntered(NSEvent())
    }
    
    func resetTrackingArea() {
        if tracksMouseEnterExit && trackingArea != nil {
            removeTrackingArea(trackingArea!)
            trackingArea = nil
            ensureTrackingArea()
        }
    }

    override func mouseDown(theEvent: NSEvent) {
        let globalLocation = theEvent.locationInWindow
        let localLocation = convertPoint(globalLocation, fromView: nil)
        let clickedRow = rowAtPoint(localLocation)
        
        super.mouseDown(theEvent)
        
        if clickedRow == -1 { return }

        extendedDelegate?.tableView(self, wasClicked: theEvent, atRow: clickedRow)
    }
    
    override func rightMouseDown(theEvent: NSEvent) {
        let globalLocation = theEvent.locationInWindow
        let localLocation = convertPoint(globalLocation, fromView: nil)
        let clickedRow = rowAtPoint(localLocation)
        
        super.rightMouseDown(theEvent)
        
        if clickedRow == -1 { return }
        
        extendedDelegate?.tableView(self, wasRightClicked: theEvent, atRow: clickedRow)
    }
    
    override func mouseMoved(theEvent: NSEvent) {
        super.mouseMoved(theEvent)
        
        let globalLocation = theEvent.locationInWindow
        let localLocation = convertPoint(globalLocation, fromView: nil)
        let newMouseInsideRow = rowAtPoint(localLocation)
        
        if newMouseInsideRow != mouseInsideRow {
            if newMouseInsideRow != -1 {
                extendedDelegate?.tableView(self, mouseEnteredRow: newMouseInsideRow)
            }
            if mouseInsideRow != -1 {
                extendedDelegate?.tableView(self, mouseExitedRow: mouseInsideRow)
            }
            mouseInsideRow = newMouseInsideRow
        }
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        super.mouseEntered(theEvent)
        
        updateTrackingAreas()
    }
    
    override func mouseExited(theEvent: NSEvent) {
        super.mouseExited(theEvent)
        
        if mouseInsideRow != -1 {
            extendedDelegate?.tableView(self, mouseExitedRow: mouseInsideRow)
            mouseInsideRow = -1
        }
    }
    
    func scrollViewDidStartScrolling(notification: NSNotification) {
        if mouseInsideRow != -1 {
            extendedDelegate?.tableView(self, mouseExitedRow: mouseInsideRow)
            mouseInsideRow = -1
        }
    }
    
    func scrollViewDidScroll(notification: NSNotification) {
        updateVisibleRows()
        extendedDelegate?.didScrollTableView(self)
    }
    
    func updateVisibleRows() {
        let newVisibleRange = rowsInRect(clipView.visibleRect).toRange()!
        let newVisibleRows = [Int](newVisibleRange)
        
        let hiddenRows = visibleRows.filter { !contains(newVisibleRows, $0) }
        let shownRows = newVisibleRows.filter { !contains(self.visibleRows, $0) }
        
//        if !shownRows.isEmpty {
//            println("Shown \(shownRows)\n\(self)")
//        }
//        if !hiddenRows.isEmpty {
//            println("Hidden \(hiddenRows)\n\(self)")
//        }
        
        if !hiddenRows.isEmpty {
            let hiddenDirection = (average(hiddenRows) > average(newVisibleRows)) ? RowShowHideDirection.Below : RowShowHideDirection.Above
            for row in hiddenRows {
                extendedDelegate?.tableView(self, rowDidHide: row, direction: hiddenDirection)
            }
        }
        
        if !shownRows.isEmpty {
            let shownDirection = (average(shownRows) > average(newVisibleRows)) ? RowShowHideDirection.Below : RowShowHideDirection.Above
            for row in shownRows {
                extendedDelegate?.tableView(self, rowDidShow: row, direction: shownDirection)
            }
        }
        
        visibleRows = newVisibleRows
    }
    
    func scrollViewDidEndScrolling(notification: NSNotification) {
        extendedDelegate?.didEndScrollingTableView(self)
    }
    
    func average(array: [Int]) -> Double {
        return Double(array.reduce(0) { $0 + $1 }) / Double(array.count)
    }
}

// TODO: Swift 2.0 update with default implementation to make these optional

protocol ExtendedTableViewDelegate {
    func tableView(tableView: ExtendedTableView, wasClicked theEvent: NSEvent, atRow row: Int)
    func tableView(tableView: ExtendedTableView, wasRightClicked theEvent: NSEvent, atRow row: Int)
    func tableView(tableView: ExtendedTableView, mouseEnteredRow row: Int)
    func tableView(tableView: ExtendedTableView, mouseExitedRow row: Int)
    func tableView(tableView: ExtendedTableView, rowDidShow row: Int, direction: RowShowHideDirection)
    func tableView(tableView: ExtendedTableView, rowDidHide row: Int, direction: RowShowHideDirection)
    func didEndScrollingTableView(tableView: ExtendedTableView)
    func didScrollTableView(tableView: ExtendedTableView)
}

enum RowShowHideDirection: Int {
    case Above
    case Below
}
