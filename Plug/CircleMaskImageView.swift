//
//  CircleMaskImageView.swift
//  Plug
//
//  Created by Alex Marchant on 9/7/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class CircleMaskImageView: NSImageView {

    override func drawRect(dirtyRect: NSRect) {
        if image != nil {
            NSGraphicsContext.saveGraphicsState()

            let path = NSBezierPath(roundedRect: bounds, xRadius: bounds.size.width / 2, yRadius: bounds.size.height / 2)
            path.addClip()
            image.drawInRect(bounds, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1)

            NSGraphicsContext.restoreGraphicsState()
        }
    }
}
