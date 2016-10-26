//
//  HyperlinkButton.swift
//  Plug
//
//  Created by Alex Marchant on 8/26/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class HyperlinkButton: NSButton {
    @IBInspectable var textColor: NSColor = NSColor.black {
        didSet { applyAttributes() }
    }
    @IBInspectable var selectedTextColor: NSColor = NSColor(red256: 255, green256: 95, blue256: 82) {
        didSet { applyAttributes() }
    }
    @IBInspectable var selected: Bool = false {
        didSet { applyAttributes() }
    }
    @IBInspectable var hoverUnderline: Bool = false
    @IBInspectable var alwaysUnderlined: Bool = false
    
    override var title: String {
        didSet { applyAttributes() }
    }
    var trackingArea: NSTrackingArea?
    var mouseInside: Bool = false {
        didSet { mouseInsideChanged() }
    }
    
    init() {
        super.init(frame: NSZeroRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        setButtonType(NSButtonType.momentaryPushIn)
        bezelStyle = NSBezelStyle.rounded
    }
    
    func applyAttributes() {
        var attributes = [String: AnyObject]()
        if selected {
            attributes[NSForegroundColorAttributeName] = selectedTextColor
        } else {
            attributes[NSForegroundColorAttributeName] = textColor
        }
        attributes[NSFontAttributeName] = (cell as! NSButtonCell).font
        let paragraphStyle = NSParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = (cell as! NSButtonCell).lineBreakMode
        attributes[NSParagraphStyleAttributeName] = paragraphStyle
        let coloredString = NSMutableAttributedString(string: title, attributes: attributes)
        attributedTitle = coloredString
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        updateTrackingAreas()
        
        if alwaysUnderlined {
            addUnderlineToText()
        }
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        if hoverUnderline && !alwaysUnderlined {
            if trackingArea != nil {
                removeTrackingArea(trackingArea!)
                trackingArea = nil
            }
            
            let options: NSTrackingAreaOptions = [.inVisibleRect, .activeAlways, .mouseEnteredAndExited]
            trackingArea = NSTrackingArea(rect: NSZeroRect, options: options, owner: self, userInfo: nil)
            addTrackingArea(trackingArea!)
        }
    }

    override func mouseEntered(with theEvent: NSEvent) {
        mouseInside = true
    }
    
    override func mouseExited(with theEvent: NSEvent) {
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
        let newAttributedTitle = NSMutableAttributedString(attributedString: attributedTitle)
        newAttributedTitle.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue, range: range)
        attributedTitle = newAttributedTitle
    }
    
    func removeUnderlineFromText() {
        let range = NSMakeRange(0, attributedTitle.length)
        let newAttributedTitle = NSMutableAttributedString(attributedString: attributedTitle)
        newAttributedTitle.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleNone.rawValue, range: range)
        attributedTitle = newAttributedTitle
    }
}
