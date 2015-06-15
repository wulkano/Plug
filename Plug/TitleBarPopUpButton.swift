//
//  TitleBarPopUpButton.swift
//  Plug
//
//  Created by Alex Marchant on 6/15/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

class TitleBarPopUpButton: NSPopUpButton {
    var formattedTitle: NSAttributedString {
        return (cell() as! TitleBarPopUpButtonCell).formattedTitle
    }
    
    var extraWidthForFormattedTitle: CGFloat {
        return (cell() as! TitleBarPopUpButtonCell).extraWidthForFormattedTitle
    }
    
    override var intrinsicContentSize: NSSize {
        var newSize = super.intrinsicContentSize
        newSize.width += extraWidthForFormattedTitle
        return newSize
    }
}