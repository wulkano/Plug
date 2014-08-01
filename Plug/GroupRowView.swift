//
//  GroupRowView.swift
//  Plug
//
//  Created by Alex Marchant on 7/31/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class GroupRowView: NSTableRowView {
    let backgroundFill = NSColor(red256: 244, green256: 244, blue256: 245)
    let lineFill = NSColor(red256: 225, green256: 230, blue256: 233)
    let selectionFill = NSColor(red256: 225, green256: 230, blue256: 233)
    
    override func drawRect(dirtyRect: NSRect) {
        if selected {
            drawSelectionInRect(dirtyRect)
        } else {
            drawBackground(dirtyRect)
            drawSeparators(dirtyRect)
        }
    }
    
    func drawBackground(dirtyRect: NSRect) {
        backgroundFill.set()
        NSRectFill(dirtyRect)
    }
    
    func drawSeparators(dirtyRect: NSRect) {
        var bottomSeparatorRect = bounds
        bottomSeparatorRect.origin.y = bounds.size.height - 1
        bottomSeparatorRect.size.height = 1
        
        lineFill.set()
        NSRectFill(NSIntersectionRect(bottomSeparatorRect, dirtyRect))
    }
    
    override func drawSelectionInRect(dirtyRect: NSRect) {
        selectionFill.set()
        NSRectFill(dirtyRect)
    }
}
