//
//  BorderedView.swift
//  Plug
//
//  Created by Alex Marchant on 7/31/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class BackgroundBorderView: NSView {
    @IBInspectable var borderWidth: CGFloat = 1
    @IBInspectable var topBorder: Bool = false
    @IBInspectable var rightBorder: Bool = false
    @IBInspectable var bottomBorder: Bool = false
    @IBInspectable var leftBorder: Bool = false
    @IBInspectable var borderColor: NSColor = NSColor.blackColor()
    
    @IBInspectable var background: Bool = false
    @IBInspectable var backgroundColor: NSColor = NSColor.whiteColor() {
        didSet { needsDisplay = true }
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        drawBackground(dirtyRect)
        drawBorder(dirtyRect)
    }
    
    func drawBackground(dirtyRect: NSRect) {
        if background {
            backgroundColor.set()
            NSRectFillUsingOperation(dirtyRect, NSCompositingOperation.CompositeSourceOver)
        }
    }
    
    func drawBorder(dirtyRect: NSRect) {
        borderColor.set()
        
        if topBorder {
            var topRect = bounds
            topRect.size.height = borderWidth
            topRect.origin.y = bounds.size.height - borderWidth
            NSRectFillUsingOperation(NSIntersectionRect(topRect, dirtyRect), .CompositeSourceOver)
        }
        
        if rightBorder {
            var rightRect = bounds
            rightRect.size.width = borderWidth
            rightRect.origin.x = bounds.size.width - borderWidth
            NSRectFillUsingOperation(NSIntersectionRect(rightRect, dirtyRect), .CompositeSourceOver)
        }
        
        if bottomBorder {
            var bottomRect = bounds
            bottomRect.size.height = borderWidth
            NSRectFillUsingOperation(NSIntersectionRect(bottomRect, dirtyRect), .CompositeSourceOver)
        }
        
        if leftBorder {
            var leftRect = bounds
            leftRect.size.width = borderWidth
            NSRectFillUsingOperation(NSIntersectionRect(leftRect, dirtyRect), .CompositeSourceOver)
        }
    }
}
