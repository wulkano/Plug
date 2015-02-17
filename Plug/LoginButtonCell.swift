//
//  LoginButtonCell.swift
//  Plug
//
//  Created by Alex Marchant on 8/25/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class LoginButtonCell: SwissArmyButtonCell {
    var loginButton: LoginButton {
        return controlView as! LoginButton
    }
    
    override func drawTitle(title: NSAttributedString, withFrame frame: NSRect, inView controlView: NSView) -> NSRect {
        
        var mutableTitle = NSMutableAttributedString(attributedString: title)
        var range = NSMakeRange(0, mutableTitle.length)
        var color = getTextColor()
        
        mutableTitle.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
        
        return super.drawTitle(mutableTitle, withFrame: frame, inView: controlView)
    }
    
    override func drawImage(image: NSImage, withFrame frame: NSRect, inView controlView: NSView) {
        
        var alpha = getImageAlpha()
        
        var newFrame = frame
        newFrame.origin.y += 3
        
        image.drawInRect(newFrame, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: alpha, respectFlipped: true, hints: nil)
    }
    
    func getTextColor() -> NSColor {
        switch loginButton.buttonState {
        case .Error:
            return NSColor(red256: 255, green256: 95, blue256: 82).colorWithAlphaComponent(getAlpha())
        default:
            return NSColor.whiteColor().colorWithAlphaComponent(getAlpha())
        }
    }
    
    func getAlpha() -> CGFloat {
        switch loginButton.buttonState {
        case .Enabled, .Error:
            if mouseDown {
                return 0.3
            } else if mouseInside {
                return 0.6
            } else {
                return 1
            }
        case .Disabled:
            return 0.5
        case .Sending:
            return 1
        }
    }
    
    func getImageAlpha() -> CGFloat {
        switch loginButton.buttonState {
        case .Sending, .Disabled:
            return 0
        default:
            return getAlpha()
        }
    }
}
