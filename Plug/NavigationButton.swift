//
//  NavigationButton.swift
//  Plug
//
//  Created by Alexander Marchant on 7/15/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class NavigationButton: NSButton {
    @IBInspectable var unselectedImage: NSImage?
    @IBInspectable var selectedImage: NSImage?
    var buttonState: NavigationButtonState = NavigationButtonState.Inactive {
    didSet {
        needsDisplay = true
    }
    }
    let inactiveOpacity: Double = 0.3
    let hoverOpacity: Double = 0.7
    let clickedOpacity: Double = 1
    let selectedOpacity: Double = 1

    override func drawRect(dirtyRect: NSRect) {
        var drawPosition = bounds
        if unselectedImage {
            drawPosition.origin.x = (bounds.size.width - unselectedImage!.size.width) / 2
            drawPosition.origin.y = -(bounds.size.height - unselectedImage!.size.height) / 2
        }
        
        switch buttonState {
        case .Inactive:
            unselectedImage?.drawInRect(drawPosition, fromRect:dirtyRect, operation:NSCompositingOperation.CompositeSourceOver, fraction:buttonState.opacity(), respectFlipped:true, hints:nil)
        case .Hover:
            unselectedImage?.drawInRect(drawPosition, fromRect:dirtyRect, operation:NSCompositingOperation.CompositeSourceOver, fraction:buttonState.opacity(), respectFlipped:true, hints:nil)
        case .Clicked:
            unselectedImage?.drawInRect(drawPosition, fromRect:dirtyRect, operation:NSCompositingOperation.CompositeSourceOver, fraction:buttonState.opacity(), respectFlipped:true, hints:nil)
        case .Selected:
            selectedImage?.drawInRect(drawPosition, fromRect:dirtyRect, operation:NSCompositingOperation.CompositeSourceOver, fraction:buttonState.opacity(), respectFlipped:true, hints:nil)
        }
    }
    
    override func viewDidMoveToWindow() {
        addTrackingRect(bounds, owner: self, userData: nil, assumeInside: false)
    }
    
    override func mouseDown(theEvent: NSEvent!) {
        if buttonState != NavigationButtonState.Selected {
            buttonState = NavigationButtonState.Clicked
        }
        super.mouseDown(theEvent)
        mouseUp(theEvent)
    }
    
    override func mouseUp(theEvent: NSEvent!) {
        buttonState = NavigationButtonState.Selected
        super.mouseUp(theEvent)
    }
    
    override func mouseEntered(theEvent: NSEvent!) {
        if buttonState != NavigationButtonState.Selected {
            buttonState = NavigationButtonState.Hover
        }
        super.mouseEntered(theEvent)
    }
    
    override func mouseExited(theEvent: NSEvent!) {
        if buttonState != NavigationButtonState.Selected {
            buttonState = NavigationButtonState.Inactive
        }
        super.mouseExited(theEvent)
    }
}

enum NavigationButtonState {
    case Inactive
    case Hover
    case Clicked
    case Selected
    
    func opacity() -> Double {
        switch self {
        case .Inactive:
            return 0.3
        case .Hover:
            return 0.7
        case .Clicked:
            return 1
        case Selected:
            return 1
        }
    }
}
