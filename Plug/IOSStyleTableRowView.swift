//
//  IOSStyleTableRowView.swift
//  Plug
//
//  Created by Alex Marchant on 8/1/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class IOSStyleTableRowView: NSTableRowView {
    override var nextRowSelected: Bool {
        didSet { needsDisplay = true }
    }
    
    @IBInspectable var separatorSpacing: CGFloat = 0
    @IBInspectable var customSeparatorColor: NSColor = NSColor(red256: 225, green256: 230, blue256: 233)
    @IBInspectable var selectionColor: NSColor = NSColor(red256: 244, green256: 244, blue256: 245)
    
    var separatorWidth: CGFloat = 1
    var nextRowIsGroupRow: Bool = false

    // MARK: Separator
    
    override func drawSeparatorInRect(dirtyRect: NSRect) {
        if shouldDrawSeparator() {
            let separatorRect = makeSeparatorRect(dirtyRect)
            customSeparatorColor.set()
            NSRectFill(separatorRect)
        }
    }
    
    func shouldDrawSeparator() -> Bool {
        if nextRowIsGroupRow { return true }
        if selected { return false }
        if nextRowSelected { return false }
        return true
    }
    
    func makeSeparatorRect(dirtyRect: NSRect) -> NSRect {
        var separatorRect = bounds
        separatorRect.size.height = separatorWidth
        if !nextRowIsGroupRow {
            separatorRect.size.width = bounds.size.width - separatorSpacing
            separatorRect.origin.x = separatorSpacing
        }
        separatorRect.origin.y = bounds.size.height - separatorWidth
        return NSIntersectionRect(separatorRect, dirtyRect)
    }
    
    // MARK: Selection
    
    override func drawSelectionInRect(dirtyRect: NSRect) {
        let selectionRect = bounds
        selectionColor.set()
        NSRectFill(selectionRect)
    }
}
