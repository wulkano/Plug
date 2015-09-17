//
//  VibrantTextField.swift
//  Plug
//
//  Created by Alex Marchant on 8/25/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class VibrantTextField: NSTextField {
    override var allowsVibrancy: Bool {
        return true
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        setupStyledPlaceholderString()
    }
    
    func setupStyledPlaceholderString() {
        if placeholderString == nil { return }
        var newAttributedPlaceholderString = NSMutableAttributedString(string: placeholderString!, attributes: placeholderAttributes())
        placeholderAttributedString = newAttributedPlaceholderString
    }
    
    func placeholderAttributes() -> [NSObject: AnyObject] {
        var attributes = [NSObject: AnyObject]()
        attributes[NSForegroundColorAttributeName] = NSColor.whiteColor().colorWithAlphaComponent(0.2)
        attributes[NSFontAttributeName] = (cell as! NSTextFieldCell).font
        return attributes
    }
}
