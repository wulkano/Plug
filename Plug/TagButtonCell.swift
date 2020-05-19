//
//  TagButtonCell.swift
//  Plug
//
//  Created by Alex Marchant on 10/7/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class TagButtonCell: SwissArmyButtonCell {
    var fillColor = NSColor.clear

    override func drawBezel(withFrame frame: NSRect, in controlView: NSView) {
        let rect = frame.insetBy(dx: 1, dy: 1)
        let roundedRect = NSBezierPath(roundedRect: rect, xRadius: 3, yRadius: 3)
        roundedRect.lineWidth = 0
        fillColor.setFill()
        roundedRect.fill()
    }

    override func drawTitle(_ title: NSAttributedString, withFrame frame: NSRect, in controlView: NSView) -> NSRect {
        var newFrame = frame
        newFrame.origin.x -= 4.5
        newFrame.size.width += 9
        return super.drawTitle(title, withFrame: newFrame, in: controlView)
    }

    override func cellSize(forBounds aRect: NSRect) -> NSSize {
        var size = super.cellSize(forBounds: aRect)
        size.width += 6
        return size
    }
}
