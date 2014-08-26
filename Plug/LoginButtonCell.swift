//
//  LoginButtonCell.swift
//  Plug
//
//  Created by Alex Marchant on 8/25/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class LoginButtonCell: NSButtonCell {
    
    override func drawTitle(title: NSAttributedString!, withFrame frame: NSRect, inView controlView: NSView!) -> NSRect {
        var mutableTitle = NSMutableAttributedString(attributedString: title)
        var range = NSMakeRange(0, mutableTitle.length)
        var color: NSColor
        if enabled {
            color = NSColor(red: 255, green: 255, blue: 255, alpha: 1)
        } else {
            color = NSColor(red: 255, green: 255, blue: 255, alpha: 0.5)
        }
        mutableTitle.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
        return super.drawTitle(mutableTitle, withFrame: frame, inView: controlView)
    }
    
    override func drawImage(image: NSImage!, withFrame frame: NSRect, inView controlView: NSView!) {
        if enabled {
            super.drawImage(image, withFrame: frame, inView: controlView)
        }
    }
}
