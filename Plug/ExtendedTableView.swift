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
    let defaultExtendedTrackingAreaInsets = NSEdgeInsets(top: 0, left: 0, bottom: 47, right: 0)
    var extendedTrackingAreaInsets: NSEdgeInsets? {
        didSet { updateExtendedTrackingArea() }
    }
    var extendedTrackingAreaRect: NSRect {
        return insetRect(clipView.documentVisibleRect, insets: extendedTrackingAreaInsets ?? defaultExtendedTrackingAreaInsets)
    }
    
    var extendedDelegate: ExtendedTableViewDelegate?
    var mouseInsideRow: Int = -1
    
    var clipView: NSClipView {
        return superview as! NSClipView
    }
    var previousVisibleRect: NSRect = NSZeroRect
    var scrollView: NSScrollView? {
        return clipView.superview as? NSScrollView
    }
    var visibleRows: [Int] {
        return [Int](rowsInRect(visibleRect).toRange()!)
    }
    var previousVisibleRows: [Int] = []
    var previousRowDidStartToHide = -1
    var previousRowDidStartToShow = -1
    
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
        let direction = scrollDirection()
        updateRowDidStartToShow(direction)
        updateRowDidStartToHide(direction)
        updateRowDidShow(direction)
        updateRowDidHide(direction)
        
        extendedDelegate?.didScrollTableView(self)
        
        previousVisibleRect = visibleRect
        previousVisibleRows = visibleRows
    }
    
    func scrollDirection() -> ScrollDirection {
        if visibleRect.origin.y >= previousVisibleRect.origin.y {
            return .Down
        } else {
            return .Up
        }
    }
    
    func updateRowDidStartToShow(scrollDirection: ScrollDirection) {
        let point: NSPoint
        let shownDirection: RowShowHideDirection
        
        let rowHeight: CGFloat = delegate()!.tableView!(self, heightOfRow: 0)
        
        switch scrollDirection {
        case .Up:
            var topPoint = visibleRect.origin
            topPoint.y = topPoint.y + rowHeight
            point = topPoint
            shownDirection = .Above
        case .Down:
            var bottomPoint = visibleRect.origin
            bottomPoint.y = bottomPoint.y + visibleRect.size.height - rowHeight
            point = bottomPoint
            shownDirection = .Below
        }
        
        let row = rowAtPoint(point)
        if row != previousRowDidStartToShow {
            extendedDelegate?.tableView(self, rowDidStartToShow: row, direction: shownDirection)
            previousRowDidStartToShow = row
        }
    }
    
    func updateRowDidStartToHide(scrollDirection: ScrollDirection) {
        let point: NSPoint
        let hiddenDirection: RowShowHideDirection
        
        switch scrollDirection {
        case .Up:
            var bottomPoint = visibleRect.origin
            bottomPoint.y = bottomPoint.y + visibleRect.size.height + 1
            point = bottomPoint
            hiddenDirection = .Below
        case .Down:
            var topPoint = visibleRect.origin
            topPoint.y = topPoint.y - 1
            point = topPoint
            hiddenDirection = .Above
        }
        
        let row = rowAtPoint(point)
        if row != previousRowDidStartToHide {
            extendedDelegate?.tableView(self, rowDidStartToHide: row, direction: hiddenDirection)
            previousRowDidStartToHide = row
        }
    }
    
    func updateRowDidShow(scrollDirection: ScrollDirection) {
        let shownDirection = scrollDirection == .Down ? RowShowHideDirection.Below : RowShowHideDirection.Above
        
        for row in newVisibleRows() {
            extendedDelegate?.tableView(self, rowDidShow: row, direction: shownDirection)
        }
    }
    
    func updateRowDidHide(scrollDirection: ScrollDirection) {
        let hiddenDirection = scrollDirection == .Down ? RowShowHideDirection.Above : RowShowHideDirection.Below
        
        for row in newHiddenRows() {
            extendedDelegate?.tableView(self, rowDidHide: row, direction: hiddenDirection)
        }
    }
    
    func newVisibleRows() -> [Int] {
        let rows = visibleRows.filter { !contains(self.previousVisibleRows, $0) }
        return rows
    }
    
    func newHiddenRows() -> [Int] {
        let rows = previousVisibleRows.filter { !contains(self.visibleRows, $0) }
        return rows
    }
    
    func scrollViewDidEndScrolling(notification: NSNotification) {
        extendedDelegate?.didEndScrollingTableView(self)
        
        updateExtendedTrackingArea()
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
    func tableView(tableView: ExtendedTableView, rowDidStartToShow row: Int, direction: RowShowHideDirection)
    func tableView(tableView: ExtendedTableView, rowDidStartToHide row: Int, direction: RowShowHideDirection)
    func didEndScrollingTableView(tableView: ExtendedTableView)
    func didScrollTableView(tableView: ExtendedTableView)
}

enum RowShowHideDirection: Int {
    case Above
    case Below
}

enum ScrollDirection {
    case Down
    case Up
}
