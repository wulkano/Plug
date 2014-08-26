//
//  ForgotPasswordButtonCell.swift
//  Plug
//
//  Created by Alex Marchant on 8/25/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class ForgotPasswordButtonCell: NSButtonCell {
    override func drawTitle(title: NSAttributedString!, withFrame frame: NSRect, inView controlView: NSView!) -> NSRect {
        var mutableTitle = NSMutableAttributedString(attributedString: title)
        let color = NSColor.whiteColor().colorWithAlphaComponent(0.2)
        let range = NSMakeRange(0, mutableTitle.length)
        
        mutableTitle.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
        
        return super.drawTitle(mutableTitle, withFrame: frame, inView: controlView)
    }
}