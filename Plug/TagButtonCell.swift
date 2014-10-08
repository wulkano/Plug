//
//  TagButtonCell.swift
//  Plug
//
//  Created by Alex Marchant on 10/7/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class TagButtonCell: SwissArmyButtonCell {
    var fillColor: NSColor = NSColor.clearColor()

    override func drawBezelWithFrame(frame: NSRect, inView controlView: NSView) {
        let rect = NSInsetRect(frame, 1, 1)
        var roundedRect = NSBezierPath(roundedRect: rect, xRadius: 3, yRadius: 3)
        roundedRect.lineWidth = 0
        fillColor.setFill()
        roundedRect.fill()
    }
    
    override func drawTitle(title: NSAttributedString, withFrame frame: NSRect, inView controlView: NSView) -> NSRect {
        var newFrame = frame
        newFrame.origin.x -= 4.5
        newFrame.size.width += 9
        return super.drawTitle(title, withFrame: newFrame, inView: controlView)
    }
    
    override func cellSizeForBounds(aRect: NSRect) -> NSSize {
        var size = super.cellSizeForBounds(aRect)
        size.width += 6
        return size
    }
}
