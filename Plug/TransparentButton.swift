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
    
    @IBInspectable var selectedOpacity: CGFloat = 1
    @IBInspectable var mouseDownOpacity: CGFloat = 1
    @IBInspectable var mouseInsideOpacity: CGFloat = 0.7
    @IBInspectable var inactiveOpacity: CGFloat = 0.3
    
    var mouseInside: Bool = false {
        didSet { needsDisplay = true }
    }
    var mouseDown: Bool = false {
        didSet { needsDisplay = true }
    }
    var selected: Bool = false {
        didSet { needsDisplay = true }
    }

    override func draw(_ dirtyRect: NSRect) {
        var drawPosition = bounds
        let drawImage = getDrawImage()
        let drawOpacity = getDrawOpacity()
        
        if drawImage != nil {
            drawPosition.origin.x = (bounds.size.width - drawImage!.size.width) / 2
            drawPosition.origin.y = -(bounds.size.height - drawImage!.size.height) / 2
        }
        
        drawImage?.draw(in: drawPosition, from:dirtyRect, operation:NSCompositingOperation.sourceOver, fraction:drawOpacity, respectFlipped:true, hints:nil)
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
    
    override func mouseDown(with theEvent: NSEvent) {
        mouseDown = true
        super.mouseDown(with: theEvent)
        mouseUp(with: theEvent)
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        mouseDown = false
        super.mouseUp(with: theEvent)
    }
    
    override func mouseEntered(with theEvent: NSEvent) {
        mouseInside = true
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        mouseInside = false
    }
}
