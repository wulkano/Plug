//
//  TransparentPushButton.swift
//  Plug
//
//  Created by Alexander Marchant on 7/20/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class TransparentButton: NSButton {
    @IBInspectable var selectable: Bool = false
    @IBInspectable var selectedImage: NSImage?
    @IBInspectable var unselectedImage: NSImage?
    
    var mouseInside: Bool = false {
        didSet { needsDisplay = true }
    }
    var mouseDown: Bool = false {
        didSet { needsDisplay = true }
    }
    var selected: Bool = false {
        didSet { needsDisplay = true }
    }
    
    let selectedOpacity: CGFloat = 1
    let mouseDownOpacity: CGFloat = 1
    let mouseInsideOpacity: CGFloat = 0.7
    let inactiveOpacity: CGFloat = 0.3
    
    override func drawRect(dirtyRect: NSRect) {
        var drawPosition = bounds
        let drawImage = getDrawImage()
        let drawOpacity = getDrawOpacity()
        
        if drawImage != nil {
            drawPosition.origin.x = (bounds.size.width - drawImage!.size.width) / 2
            drawPosition.origin.y = -(bounds.size.height - drawImage!.size.height) / 2
        }
        
        drawImage?.drawInRect(drawPosition, fromRect:dirtyRect, operation:NSCompositingOperation.CompositeSourceOver, fraction:drawOpacity, respectFlipped:true, hints:nil)
    }
    
    override func viewDidMoveToWindow() {
        addTrackingRect(bounds, owner: self, userData: nil, assumeInside: false)
    }
    
    func getDrawImage() -> NSImage? {
        if selectable && selected {
            return selectedImage
        } else {
            return unselectedImage
        }
    }
    
    func getDrawOpacity() -> CGFloat {
        if selectable && selected {
            return selectedOpacity
        } else if mouseDown {
            return mouseDownOpacity
        } else if mouseInside {
            return mouseInsideOpacity
        } else {
            return inactiveOpacity
        }
    }
    
    func toggleSelected() {
        if selected {
            selected = false
        } else {
            selected = true
        }
    }
    
    override func mouseDown(theEvent: NSEvent!) {
        mouseDown = true
        super.mouseDown(theEvent)
        mouseUp(theEvent)
    }
    
    override func mouseUp(theEvent: NSEvent!) {
        mouseDown = false
        super.mouseUp(theEvent)
    }
    
    override func mouseEntered(theEvent: NSEvent!) {
        mouseInside = true
        super.mouseEntered(theEvent)
    }
    
    override func mouseExited(theEvent: NSEvent!) {
        mouseInside = false
        super.mouseExited(theEvent)
    }
}