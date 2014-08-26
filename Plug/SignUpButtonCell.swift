//
//  SignUpButtonCell.swift
//  Plug
//
//  Created by Alex Marchant on 8/25/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class SignUpButtonCell: NSButtonCell {
    override func drawBezelWithFrame(frame: NSRect, inView controlView: NSView!) {
        let radius: CGFloat = 3
        let strokeWidth: CGFloat = 1
        let strokeColor: NSColor = NSColor.whiteColor().colorWithAlphaComponent(0.1)
        
        var rect = NSMakeRect(0.5, 0.5, frame.size.width - 1, frame.size.height - 1)
        var roundedRect = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
        roundedRect.lineWidth = strokeWidth
        strokeColor.set()
        roundedRect.stroke()
    }
    
    override func drawTitle(title: NSAttributedString!, withFrame frame: NSRect, inView controlView: NSView!) -> NSRect {
        var mutableTitle = NSMutableAttributedString(attributedString: title)
        let color = NSColor.whiteColor().colorWithAlphaComponent(0.5)
        let range = NSMakeRange(0, mutableTitle.length)
        
        mutableTitle.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
        
        return super.drawTitle(mutableTitle, withFrame: frame, inView: controlView)
    }
}
