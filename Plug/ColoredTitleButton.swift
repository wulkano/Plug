//
//  ColoredTitleButton.swift
//  Plug
//
//  Created by Alex Marchant on 8/24/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class ColoredTitleButton: NSButton {
    @IBInspectable var textColor: NSColor = NSColor.white {
        didSet {
            applyTextColor()
        }
    }
    override var attributedTitle: NSAttributedString {
        didSet {
            applyTextColor()
        }
    }
    
    func applyTextColor() {
        let textToStyle = NSMutableAttributedString(attributedString: attributedTitle)
        let range = NSMakeRange(0, textToStyle.length)
		textToStyle.addAttribute(NSAttributedString.Key.foregroundColor, value: textColor, range: range)
    }
}
