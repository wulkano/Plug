//
//  UnderlinedTabViewItem.swift
//  Plug
//
//  Created by Alex Marchant on 8/25/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class UnderlinedTabButtonCell: NSButtonCell {
    var highlightColor: NSColor = NSColor(red256: 69, green256: 159, blue256: 255)
    var hightlightWidth: CGFloat = 4
    
    
    override func drawBezelWithFrame(frame: NSRect, inView controlView: NSView!) {
        if state == NSOnState {
            var highlightRect = NSMakeRect(0, frame.size.height - hightlightWidth, frame.size.width, hightlightWidth)
            highlightColor.set()
            NSRectFill(highlightRect)
        }
    }
}
