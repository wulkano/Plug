//
//  TitleBarPopUpButton.swift
//  Plug
//
//  Created by Alex Marchant on 6/15/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

class TitleBarPopUpButton: NSPopUpButton {
    var titleBarPopUpButtonCell: TitleBarPopUpButtonCell {
        return cell() as! TitleBarPopUpButtonCell
    }
    var formattedTitle: NSAttributedString {
        return titleBarPopUpButtonCell.formattedTitle
    }
    var extraWidthForFormattedTitle: CGFloat {
        return titleBarPopUpButtonCell.extraWidthForFormattedTitle
    }
    var extraHeightForFormattedTitle: CGFloat {
        return titleBarPopUpButtonCell.extraHeightForFormattedTitle
    }
    var trimPaddingBetweenArrowAndTitle: CGFloat {
        return titleBarPopUpButtonCell.trimPaddingBetweenArrowAndTitle
    }
    
    override var intrinsicContentSize: NSSize {
        var newSize = super.intrinsicContentSize
        newSize.width += extraWidthForFormattedTitle - trimPaddingBetweenArrowAndTitle
        newSize.height += extraHeightForFormattedTitle
        return newSize
    }
}