//
//  PlaylistTableRowView.swift
//  Plug
//
//  Created by Alexander Marchant on 7/17/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PlaylistTableRowView: NSTableRowView {
    let dividerColor = NSColor(red256: 225, green256: 230, blue256: 233)
    let selectionColor = NSColor(red256: 225, green256: 230, blue256: 233)
    
    init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        drawDividerLine(dirtyRect)
    }
    
    func drawDividerLine(dirtyRect: NSRect) {
        let xOffset: Double = 72
        let lineRect = NSMakeRect(xOffset, bounds.size.height - 1, bounds.size.width - xOffset, 1)
        let drawingRect = NSIntersectionRect(dirtyRect, lineRect)
        dividerColor.set()
        NSRectFill(drawingRect)
    }
    
    override func drawSelectionInRect(dirtyRect: NSRect) {
        selectionColor.set()
        NSRectFill(dirtyRect)
    }
}
