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
    var buttonState: ButtonState = ButtonState.Off {
    didSet {
        needsDisplay = true
    }
    }
    var trackingArea: NSTrackingArea?
    
    override func drawRect(dirtyRect: NSRect) {
        var drawImage: NSImage?
        switch buttonState {
        case .On:
            drawImage = onImage
        case .OnHover:
            drawImage = onHoverImage
        case .Off:
            drawImage = offImage
        case .OffHover:
            drawImage = offHoverImage
        }
        
        var drawPosition = bounds
        if drawImage {
            drawPosition.origin.x = (bounds.size.width - drawImage!.size.width) / 2
            drawPosition.origin.y = -(bounds.size.height - drawImage!.size.height) / 2
        }
        
        drawImage?.drawInRect(drawPosition, fromRect:dirtyRect, operation:NSCompositingOperation.CompositeSourceOver, fraction:1, respectFlipped:true, hints:nil)
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        ensureTrackingArea()
        if !trackingAreas.bridgeToObjectiveC().containsObject(trackingArea) {
            addTrackingArea(trackingArea)
        }
    }
    
    func ensureTrackingArea() {
        if !trackingArea {
            trackingArea = NSTrackingArea(rect: NSZeroRect, options: NSTrackingAreaOptions.InVisibleRect | NSTrackingAreaOptions.ActiveAlways | NSTrackingAreaOptions.MouseEnteredAndExited, owner: self, userInfo: nil)
        }
    }
    
    override func mouseEntered(theEvent: NSEvent!) {
        buttonState = buttonState.hoverStateForCurrentState()
    }
    
    override func mouseExited(theEvent: NSEvent!) {
        buttonState = buttonState.normalStateForCurrentState()
    }
    
    override func mouseDown(theEvent: NSEvent!) {
        super.mouseDown(theEvent)
        mouseUp(theEvent)
    }
    
    override func mouseUp(theEvent: NSEvent!) {
        buttonState = buttonState.hoverStateForOppositeState()
        super.mouseUp(theEvent)
    }
    
    enum ButtonState {
        case On
        case OnHover
        case Off
        case OffHover
        
        func hoverStateForCurrentState() -> ButtonState {
            switch self {
            case .On:
                return .OnHover
            case .OnHover:
                return .OnHover
            case .Off:
                return .OffHover
            case .OffHover:
                return .OffHover
            }
        }
        
        func normalStateForCurrentState() -> ButtonState {
            switch self {
            case .On:
                return .On
            case .OnHover:
                return .On
            case .Off:
                return .Off
            case .OffHover:
                return .Off
            }
        }
        
        func hoverStateForOppositeState() -> ButtonState {
            switch self {
            case .On:
                return .OffHover
            case .OnHover:
                return .OffHover
            case .Off:
                return .OnHover
            case .OffHover:
                return .OnHover
            }
        }
    }
}
