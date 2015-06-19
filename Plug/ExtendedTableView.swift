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
    
    var extendedTrackingArea: NSTrackingArea?
    var extendedTrackingAreaInsets: NSEdgeInsets = NSEdgeInsets(top: 0, left: 0, bottom: 47, right: 0) {
        didSet { updateExtendedTrackingArea() }
    }
    var extendedTrackingAreaRect: NSRect {
        return insetRect(scrollView!.bounds, insets: extendedTrackingAreaInsets)
    }
    
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
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        Notifications.subscribe(observer: self, selector: "scrollViewDidStartScrolling:", name: NSScrollViewWillStartLiveScrollNotification, object: scrollView)
        Notifications.subscribe(observer: self, selector: "scrollViewDidScroll:", name: NSScrollViewDidLiveScrollNotification, object: scrollView)
        Notifications.subscribe(observer: self, selector: "scrollViewDidEndScrolling:", name: NSScrollViewDidEndLiveScrollNotification, object: scrollView)
        
        updateExtendedTrackingArea()
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        updateExtendedTrackingArea()
    }
    
    func updateExtendedTrackingArea() {
        if extendedTrackingArea != nil {
            removeTrackingArea(extendedTrackingArea!)
        }
        
        let options: NSTrackingAreaOptions = (.ActiveAlways | .MouseEnteredAndExited | .MouseMoved | .AssumeInside)
        extendedTrackingArea = NSTrackingArea(rect: extendedTrackingAreaRect, options: options, owner: self, userInfo: nil)
        addTrackingArea(extendedTrackingArea!)
    }
    
    func insetRect(rect: NSRect, insets: NSEdgeInsets) -> NSRect {
        var newRect = rect
        newRect.origin.x -= insets.left
        newRect.origin.y -= insets.top
        newRect.size.width -= insets.right
        newRect.size.height -= insets.bottom
        
        if newRect.origin.x < 0 { newRect.origin.x = 0 }
        if newRect.origin.y < 0 { newRect.origin.y = 0 }
        if newRect.size.width < 0 { newRect.size.width = 0 }
        if newRect.size.height < 0 { newRect.size.height = 0 }
        
        return newRect
    }

    override func mouseDown(theEvent: NSEvent) {
        let clickedRow = rowForEvent(theEvent)
        
        super.mouseDown(theEvent)
        
        if clickedRow == -1 { return }

        extendedDelegate?.tableView(self, wasClicked: theEvent, atRow: clickedRow)
    }
    
    override func rightMouseDown(theEvent: NSEvent) {
        let clickedRow = rowForEvent(theEvent)
        
        super.rightMouseDown(theEvent)
        
        if clickedRow == -1 { return }
        
        extendedDelegate?.tableView(self, wasRightClicked: theEvent, atRow: clickedRow)
    }
    
    override func mouseMoved(theEvent: NSEvent) {
        super.mouseMoved(theEvent)
        
        let newMouseInsideRow = rowForEvent(theEvent)
        
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
    
    func rowForEvent(theEvent: NSEvent) -> Int {
        let globalLocation = theEvent.locationInWindow
        let localLocation = convertPoint(globalLocation, fromView: nil)
        return rowAtPoint(localLocation)
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        super.mouseEntered(theEvent)
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
