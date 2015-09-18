//
//  ToggleButton.swift
//  Plug
//
//  Created by Alexander Marchant on 7/18/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class HoverToggleButton: NSButton {
    @IBInspectable var onImage: NSImage?
    @IBInspectable var onHoverImage: NSImage?
    @IBInspectable var offImage: NSImage?
    @IBInspectable var offHoverImage: NSImage?

    var trackingArea: NSTrackingArea?
    var mouseInside: Bool = false {
        didSet { needsDisplay = true }
    }
    var selected: Bool = false {
        didSet { needsDisplay = true }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        
        let drawImage = getDrawImage()
        
        var drawPosition = bounds
        if drawImage != nil {
            drawPosition.origin.x = (bounds.size.width - drawImage!.size.width) / 2
            drawPosition.origin.y = -(bounds.size.height - drawImage!.size.height) / 2
        }
        
        drawImage?.drawInRect(drawPosition, fromRect:dirtyRect, operation:NSCompositingOperation.CompositeSourceOver, fraction:1, respectFlipped:true, hints:nil)
    }
    
    func getDrawImage() -> NSImage? {
        if selected && mouseInside {
            return onHoverImage
        } else if selected {
            return onImage
        } else if mouseInside {
            return offHoverImage
        } else {
            return offImage
        }
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        updateTrackingAreas()
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        if trackingArea != nil {
            removeTrackingArea(trackingArea!)
            trackingArea = nil
        }
        
        let options: NSTrackingAreaOptions = [.InVisibleRect, .ActiveAlways, .MouseEnteredAndExited]
        trackingArea = NSTrackingArea(rect: NSZeroRect, options: options, owner: self, userInfo: nil)
        addTrackingArea(trackingArea!)
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        mouseInside = true
    }
    
    override func mouseExited(theEvent: NSEvent) {
        mouseInside = false
    }
}
