//
//  PostInfoTextField.swift
//  Plug
//
//  Created by Alex Marchant on 10/9/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PostInfoTextField: NSTextField {
    var postInfoDelegate: PostInfoTextFieldDelegate?
    var trackingArea: NSTrackingArea?
    var mouseInside = false
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        ensureTrackingArea()
        if find(trackingAreas as [NSTrackingArea], trackingArea!) == nil {
            addTrackingArea(trackingArea!)
        }
    }
    
    func ensureTrackingArea() {
        if trackingArea == nil {
            trackingArea = NSTrackingArea(rect: NSZeroRect, options: NSTrackingAreaOptions.InVisibleRect | NSTrackingAreaOptions.ActiveAlways | NSTrackingAreaOptions.MouseEnteredAndExited, owner: self, userInfo: nil)
        }
    }
    
    override func mouseDown(theEvent: NSEvent) {
        postInfoDelegate?.postInfoTextFieldClicked(self)
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        mouseInside = true
        updateText()
    }
    
    override func mouseExited(theEvent: NSEvent) {
        mouseInside = false
        updateText()
    }
    
    func updateText() {
        if mouseInside {
            var contents = NSMutableAttributedString(attributedString: attributedStringValue)
            contents.enumerateAttribute(NSLinkAttributeName, inRange: NSMakeRange(0, contents.length), options: NSAttributedStringEnumerationOptions.LongestEffectiveRangeNotRequired , usingBlock: { value, range, stop in
                if value != nil {
                    contents.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyleSingle, range: range)
                }
            })
            attributedStringValue = contents
        } else {
            var contents = NSMutableAttributedString(attributedString: attributedStringValue)
            contents.enumerateAttribute(NSLinkAttributeName, inRange: NSMakeRange(0, contents.length), options: NSAttributedStringEnumerationOptions.LongestEffectiveRangeNotRequired , usingBlock: { value, range, stop in
                if value != nil {
                    contents.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyleNone, range: range)
                }
            })
            attributedStringValue = contents
        }
    }
}

protocol PostInfoTextFieldDelegate {
    func postInfoTextFieldClicked(sender: AnyObject)
}
