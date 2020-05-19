//
//  ForgotPasswordButtonCell.swift
//  Plug
//
//  Created by Alex Marchant on 8/25/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class ForgotPasswordButtonCell: SwissArmyButtonCell {
    override func drawBezel(withFrame frame: NSRect, in controlView: NSView) {
    }

    override func drawTitle(_ title: NSAttributedString, withFrame frame: NSRect, in controlView: NSView) -> NSRect {
        var alpha: CGFloat

        if mouseDown {
            alpha = 1
        } else if mouseInside {
            alpha = 0.5
        } else {
            alpha = 0.2
        }

        let mutableTitle = NSMutableAttributedString(attributedString: title)
        let color = NSColor.white.withAlphaComponent(alpha)
        let range = NSRange(location: 0, length: mutableTitle.length)

		mutableTitle.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)

        return super.drawTitle(mutableTitle, withFrame: frame, in: controlView)
    }
}
