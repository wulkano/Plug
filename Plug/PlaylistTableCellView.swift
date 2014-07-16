//
//  PlaylistTableCellView.swift
//  Plug
//
//  Created by Alexander Marchant on 7/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PlaylistTableCellView: NSTableCellView {
    var dividerColor = NSColor(red256: 225, green256: 230, blue256: 233)
    var selectedColor = NSColor(red256: 225, green256: 230, blue256: 233)
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        let xOffset: CGFloat = 70
        let lineRect = NSMakeRect(xOffset, 0, bounds.width - xOffset, 1)
        let dividerColor = NSColor(red256: 225, green256: 230, blue256: 233)
        
        dividerColor.set()
        NSRectFill(lineRect)
    }
    
}
