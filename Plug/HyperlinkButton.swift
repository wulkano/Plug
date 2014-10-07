//
//  HyperlinkButton.swift
//  Plug
//
//  Created by Alex Marchant on 8/26/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class HyperlinkButton: NSButton {
    @IBInspectable var textColor: NSColor = NSColor.blackColor() {
        didSet {
            applyAttributes()
        }
    }
    @IBInspectable var selectedTextColor: NSColor = NSColor(red256: 255, green256: 95, blue256: 82) {
        didSet {
            applyAttributes()
        }
    }
    @IBInspectable var selected: Bool = false {
        didSet {
            applyAttributes()
        }
    }
    @IBInspectable var hoverUnderline: Bool = false
    
    override var title: String {
        didSet {
            applyAttributes()
        }
    }
    var trackingArea: NSTrackingArea?
    var mouseInside: Bool = false {
        didSet {
            mouseInsideChanged()
        }
    }
    
    func applyAttributes() {
        var attributes = [NSObject: AnyObject]()
        if selected {
            attributes[NSForegroundColorAttributeName] = selectedTextColor
        } else {
            attributes[NSForegroundColorAttributeName] = textColor
        }
        attributes[NSFontAttributeName] = (cell() as NSButtonCell).font
        var paragraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = (cell() as NSButtonCell).lineBreakMode
        attributes[NSParagraphStyleAttributeName] = paragraphStyle
        var coloredString = NSMutableAttributedString(string: title, attributes: attributes)
        attributedTitle = coloredString
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        if hoverUnderline {
            ensureTrackingArea()
            if find(trackingAreas as [NSTrackingArea], trackingArea!) == nil {
                addTrackingArea(trackingArea!)
            }
        }
    }
    
    func ensureTrackingArea() {
        if trackingArea == nil {
            trackingArea = NSTrackingArea(rect: NSZeroRect, options: NSTrackingAreaOptions.InVisibleRect | NSTrackingAreaOptions.ActiveAlways | NSTrackingAreaOptions.MouseEnteredAndExited, owner: self, userInfo: nil)
        }
    }

    override func mouseEntered(theEvent: NSEvent) {
        mouseInside = true
    }
    
    override func mouseExited(theEvent: NSEvent) {
        mouseInside = false
    }
    
    func mouseInsideChanged() {
        if mouseInside {
            addUnderlineToText()
        } else {
            removeUnderlineFromText()
        }
    }
    
    func addUnderlineToText() {
        let range = NSMakeRange(0, attributedTitle.length)
        var newAttributedTitle = NSMutableAttributedString(attributedString: attributedTitle)
        newAttributedTitle.addAttribute(NSUnderlineStyleAttributeName, value: NSSingleUnderlineStyle, range: range)
        attributedTitle = newAttributedTitle
    }
    
    func removeUnderlineFromText() {
        let range = NSMakeRange(0, attributedTitle.length)
        var newAttributedTitle = NSMutableAttributedString(attributedString: attributedTitle)
        newAttributedTitle.addAttribute(NSUnderlineStyleAttributeName, value: NSNoUnderlineStyle, range: range)
        attributedTitle = newAttributedTitle
    }
}
