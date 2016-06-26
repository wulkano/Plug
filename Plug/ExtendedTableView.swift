//
//  ExtendedTableView.swift
//  Plug
//
//  Created by Alex Marchant on 9/5/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class ExtendedTableView: NSTableView, RefreshScrollViewBoundsChangedDelegate {
    @IBInspectable var tracksMouseEnterExit: Bool = false
    @IBInspectable var pullToRefresh: Bool = false
    
    var scrollEnabled = true
    
    var isScrolling = false
    var isScrollingTimer: Interval?
    
    var trackingArea: NSTrackingArea?
    
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
    var previousRowDidHide = -1
    var previousRowDidShow = -1
    var previousScrollDirection = ScrollDirection.Up
    
    deinit {
        Notifications.unsubscribeAll(observer: self)
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        updateContentInsets()
        updateScrollerInsets()
        updateTrackingAreas()
    }
    
    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
    
        if let refreshScrollView = scrollView as? RefreshScrollView {
            refreshScrollView.boundsChangedDelegate = self
        }
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        if trackingArea != nil {
            removeTrackingArea(trackingArea!)
            trackingArea = nil
        }
        
        let options: NSTrackingAreaOptions = [.ActiveAlways, .MouseEnteredAndExited, .MouseMoved, .AssumeInside]
        let trackingRect = insetRect(clipView.documentVisibleRect, insets: scrollerInsets)
        trackingArea = NSTrackingArea(rect: trackingRect, options: options, owner: self, userInfo: nil)
        addTrackingArea(trackingArea!)
    }
    
    func insetRect(rect: NSRect, insets: NSEdgeInsets) -> NSRect {
        if rect == NSZeroRect { return rect }
        
        var newRect = rect
        
        newRect.origin.x += insets.left
        newRect.origin.y += insets.top
        newRect.size.width -= insets.left
        newRect.size.width -= insets.right
        newRect.size.height -= insets.top
        newRect.size.height -= insets.bottom
        
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
    
    func scrollViewBoundsDidChange(notification: NSNotification) {
        if !isScrolling {
            isScrolling = true
            scrollViewDidStartScrolling(notification)
        } else {
            scrollViewDidScroll(notification)
            startTimerForEndScrolling()
        }
    }
    
    func startTimerForEndScrolling() {
        isScrollingTimer?.invalidate()
        isScrollingTimer = Interval.single(0.1) {
            self.isScrolling = false
            self.scrollViewDidEndScrolling(NSNotification(name: "nil", object: self))
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
        
        previousScrollDirection = direction
    }
    
    
    func scrollViewDidEndScrolling(notification: NSNotification) {
        extendedDelegate?.didEndScrollingTableView(self)
    }
    
    func scrollDirection() -> ScrollDirection {
        if visibleRect.origin.y >= previousVisibleRect.origin.y {
            return .Down
        } else {
            return .Up
        }
    }
    
    // TODO: NOT DRY, PLZ FIX
    // If you're looking at this in > 1 month, you're an idiot
    // and you knew you'd just procrastinate fixing this
    // shitty code. But at least you were self-aware enough
    // to know, that's something right?
    
    func updateRowDidStartToShow(scrollDirection: ScrollDirection) {
        let point: NSPoint
        let shownDirection: RowShowHideDirection
        
        switch scrollDirection {
        case .Up:
            var topPoint = visibleRect.origin
            topPoint.y += contentInsets.top
            point = topPoint
            shownDirection = .Above
        case .Down:
            var bottomPoint = visibleRect.origin
            bottomPoint.y += clipView.frame.size.height
            bottomPoint.y -= contentInsets.bottom
            point = bottomPoint
            shownDirection = .Below
        }
        
        let row = rowAtPoint(point)
        if row != previousRowDidStartToShow {
            if (scrollDirection == previousScrollDirection &&
                row != -1 &&
                previousRowDidStartToHide != -1) {
                for eachRow in rangeBetweenCurrentRow(row, andPreviousRow: previousRowDidStartToShow) {
                    extendedDelegate?.tableView(self, rowDidStartToShow: eachRow, direction: shownDirection)
                }
            } else {
                extendedDelegate?.tableView(self, rowDidStartToShow: row, direction: shownDirection)
            }
            previousRowDidStartToShow = row
        }
    }
    
    func updateRowDidStartToHide(scrollDirection: ScrollDirection) {
        let point: NSPoint
        let hiddenDirection: RowShowHideDirection
        
        switch scrollDirection {
        case .Up:
            var bottomPoint = visibleRect.origin
            bottomPoint.y += clipView.frame.size.height
            bottomPoint.y -= contentInsets.bottom
            bottomPoint.y += 1
            point = bottomPoint
            hiddenDirection = .Below
        case .Down:
            var topPoint = visibleRect.origin
            topPoint.y += contentInsets.top
            topPoint.y -= 1
            point = topPoint
            hiddenDirection = .Above
        }
        
        let row = rowAtPoint(point)
        if row != previousRowDidStartToHide {
            if (scrollDirection == previousScrollDirection &&
                row != -1 &&
                previousRowDidStartToHide != -1) {
                for eachRow in rangeBetweenCurrentRow(row, andPreviousRow: previousRowDidStartToHide) {
                    extendedDelegate?.tableView(self, rowDidStartToHide: eachRow, direction: hiddenDirection)
                }
            } else {
                extendedDelegate?.tableView(self, rowDidStartToHide: row, direction: hiddenDirection)
            }
            previousRowDidStartToHide = row
        }
    }
    
    func updateRowDidShow(scrollDirection: ScrollDirection) {
        let point: NSPoint
        let shownDirection: RowShowHideDirection
        
        let rowHeight: CGFloat = delegate()!.tableView!(self, heightOfRow: 0)
        
        switch scrollDirection {
        case .Up:
            var topPoint = visibleRect.origin
            topPoint.y += rowHeight
            topPoint.y += contentInsets.top
            topPoint.y -= 1
            point = topPoint
            shownDirection = .Above
        case .Down:
            var bottomPoint = visibleRect.origin
            bottomPoint.y += clipView.frame.size.height
            bottomPoint.y -= rowHeight
            bottomPoint.y -= contentInsets.bottom
            bottomPoint.y += 1
            point = bottomPoint
            shownDirection = .Below
        }
        
        let row = rowAtPoint(point)
        if row != previousRowDidShow {
            if (scrollDirection == previousScrollDirection &&
                row != -1 &&
                previousRowDidShow != -1) {
                for eachRow in rangeBetweenCurrentRow(row, andPreviousRow: previousRowDidShow) {
                    extendedDelegate?.tableView(self, rowDidShow: eachRow, direction: shownDirection)
                }
            } else {
                extendedDelegate?.tableView(self, rowDidShow: row, direction: shownDirection)
            }
            previousRowDidShow = row
        }
    }
    
    func updateRowDidHide(scrollDirection: ScrollDirection) {
        let point: NSPoint
        let hiddenDirection: RowShowHideDirection
        
        let rowHeight: CGFloat = delegate()!.tableView!(self, heightOfRow: 0)
        
        switch scrollDirection {
        case .Up:
            var bottomPoint = visibleRect.origin
            bottomPoint.y += clipView.frame.size.height
            bottomPoint.y += rowHeight
            bottomPoint.y -= contentInsets.bottom
            bottomPoint.y += 1
            point = bottomPoint
            hiddenDirection = .Below
        case .Down:
            var topPoint = visibleRect.origin
            topPoint.y -= rowHeight
            topPoint.y += contentInsets.top
            topPoint.y -= 1
            point = topPoint
            hiddenDirection = .Above
        }
        
        let row = rowAtPoint(point)
        if row != previousRowDidHide {
            if (scrollDirection == previousScrollDirection &&
                row != -1 &&
                previousRowDidHide != -1) {
                for eachRow in rangeBetweenCurrentRow(row, andPreviousRow: previousRowDidHide) {
                    extendedDelegate?.tableView(self, rowDidHide: eachRow, direction: hiddenDirection)
                }
            } else {
                extendedDelegate?.tableView(self, rowDidHide: row, direction: hiddenDirection)
            }
            previousRowDidHide = row
        }
    }
    
    // When you scroll fast sometimes we don't detect all rows being scrolled over
    // so this makes sure to catch any skipped rows
    func rangeBetweenCurrentRow(currentRow: Int, andPreviousRow previousRow: Int) -> Range<Int> {
        if currentRow > previousRow {
            return (previousRow + 1)...currentRow
        } else {
            return currentRow...(previousRow - 1)
        }
    }
    
    func newVisibleRows() -> [Int] {
        let rows = visibleRows.filter { !self.previousVisibleRows.contains($0) }
        return rows
    }
    
    func newHiddenRows() -> [Int] {
        let rows = previousVisibleRows.filter { !self.visibleRows.contains($0) }
        return rows
    }
    
    func average(array: [Int]) -> Double {
        return Double(array.reduce(0) { $0 + $1 }) / Double(array.count)
    }
    
    // MARK: insets
    
    var contentInsets: NSEdgeInsets = NSEdgeInsetsZero {
        didSet { updateContentInsets() }
    }
    var scrollerInsets: NSEdgeInsets = NSEdgeInsetsZero {
        didSet { updateScrollerInsets() }
    }
    
    func updateContentInsets() {
        clipView.automaticallyAdjustsContentInsets = false
        clipView.contentInsets = contentInsets
    }
    
    func updateScrollerInsets() {
        scrollView!.scrollerInsets = scrollerInsets
        updateTrackingAreas()
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
