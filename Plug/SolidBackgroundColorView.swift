//
//  SolidBackgroundColorView.swift
//  Plug
//
//  Created by Alexander Marchant on 7/15/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class SolidBackgroundColorView: NSView {
    @IBInspectable var color: NSColor = NSColor.clearColor()

    override var allowsVibrancy: Bool {
        return true
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        color.set()
        NSRectFill(dirtyRect)
        // Drawing code here.
    }
    
}
