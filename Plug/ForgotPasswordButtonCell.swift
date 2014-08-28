//
//  ForgotPasswordButtonCell.swift
//  Plug
//
//  Created by Alex Marchant on 8/25/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class ForgotPasswordButtonCell: SwissArmyButtonCell {
    override func drawBezelWithFrame(frame: NSRect, inView controlView: NSView!) {
    }
    
    override func drawTitle(title: NSAttributedString!, withFrame frame: NSRect, inView controlView: NSView!) -> NSRect {
        
        var alpha: CGFloat
        
        if mouseDown {
            alpha = 1
        } else if mouseInside {
            alpha = 0.5
        } else {
            alpha = 0.2
        }
        
        var mutableTitle = NSMutableAttributedString(attributedString: title)
        let color = NSColor.whiteColor().colorWithAlphaComponent(alpha)
        let range = NSMakeRange(0, mutableTitle.length)
        
        mutableTitle.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
        
        return super.drawTitle(mutableTitle, withFrame: frame, inView: controlView)
    }
}