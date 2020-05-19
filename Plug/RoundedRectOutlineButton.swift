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
    @IBInspectable var strokeColor: NSColor = NSColor.white

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let rect = NSRect(x: 0.5, y: 0.5, width: bounds.size.width - 1, height: bounds.size.height - 1)
        let roundedRect = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
        roundedRect.lineWidth = strokeWidth
        strokeColor.set()
        roundedRect.stroke()
    }
}
