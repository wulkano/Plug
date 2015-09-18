//
//  RoundedRectOutlineButton.swift
//  Plug
//
//  Created by Alex Marchant on 8/25/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class RoundedRectOutlineButton: NSButton {
    @IBInspectable var radius: CGFloat = 3
    @IBInspectable var strokeWidth: CGFloat = 1
    @IBInspectable var strokeColor: NSColor = NSColor.whiteColor()

    override func drawRect(dirtyRect: NSRect) {
        
        super.drawRect(dirtyRect)
        
        let rect = NSMakeRect(0.5, 0.5, bounds.size.width - 1, bounds.size.height - 1)
        let roundedRect = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
        roundedRect.lineWidth = strokeWidth
        strokeColor.set()
        roundedRect.stroke()
    }
}
