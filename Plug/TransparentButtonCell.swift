//
//  NavigationButtonCell.swift
//  Plug
//
//  Created by Alex Marchant on 9/10/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class TransparentButtonCell: SwissArmyButtonCell {
    let selectedOpacity: CGFloat = 1
    let mouseDownOpacity: CGFloat = 1
    let mouseInsideOpacity: CGFloat = 0.7
    let inactiveOpacity: CGFloat = 0.3
    
    override func drawImage(image: NSImage!, withFrame frame: NSRect, inView controlView: NSView!) {
        
        var alpha = getImageAlpha()
        if let drawImage = getDrawImage() {
            drawImage.drawInRect(frame, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: alpha, respectFlipped: true, hints: nil)
        }
    }
    
    func getImageAlpha() -> CGFloat {
        if state == NSOnState {
            return selectedOpacity
        } else if mouseDown {
            return mouseDownOpacity
        } else if mouseInside {
            return mouseInsideOpacity
        } else {
            return inactiveOpacity
        }
    }
    
    func getDrawImage() -> NSImage? {
        if state == NSOnState {
            return alternateImage ?? image
        } else if mouseDown {
            return image
        } else if mouseInside {
            return image
        } else {
            return image
        }
    }
    
}
