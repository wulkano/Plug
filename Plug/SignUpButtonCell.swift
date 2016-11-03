//
//  SignUpButtonCell.swift
//  Plug
//
//  Created by Alex Marchant on 8/25/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class SignUpButtonCell: SwissArmyButtonCell {
    
    override func drawBezel(withFrame frame: NSRect, in controlView: NSView) {
        
        var alpha: CGFloat
        
        if mouseDown {
            alpha = 1
        } else if mouseInside {
            alpha = 0.5
        } else {
            alpha = 0.15
        }
        
        let radius: CGFloat = 3
        let strokeWidth: CGFloat = 1
        let strokeColor: NSColor = NSColor.white.withAlphaComponent(alpha)
        
        let rect = NSMakeRect(0.5, 0.5, frame.size.width - 1, frame.size.height - 1)
        let roundedRect = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
        roundedRect.lineWidth = strokeWidth
        strokeColor.set()
        roundedRect.stroke()
    }
    
    override func drawTitle(_ title: NSAttributedString, withFrame frame: NSRect, in controlView: NSView) -> NSRect {
        
        var alpha: CGFloat
        
        if mouseDown {
            alpha = 1
        } else if mouseInside {
            alpha = 0.8
        } else {
            alpha = 0.5
        }
        
        let mutableTitle = NSMutableAttributedString(attributedString: title)
        let color = NSColor.white.withAlphaComponent(alpha)
        let range = NSMakeRange(0, mutableTitle.length)
        
        mutableTitle.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
        
        return super.drawTitle(mutableTitle, withFrame: frame, in: controlView)
    }
}
