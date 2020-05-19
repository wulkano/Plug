//
//	TitleBarPopUpButton.swift
//	Plug
//
//	Created by Alex Marchant on 6/15/15.
//	Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

class TitleBarPopUpButton: NSPopUpButton {
	var titleBarPopUpButtonCell: TitleBarPopUpButtonCell {
		cell as! TitleBarPopUpButtonCell
	}

	var formattedTitle: NSAttributedString {
		titleBarPopUpButtonCell.formattedTitle
	}

	var extraWidthForFormattedTitle: CGFloat {
		titleBarPopUpButtonCell.extraWidthForFormattedTitle
	}

	var extraHeightForFormattedTitle: CGFloat {
		titleBarPopUpButtonCell.extraHeightForFormattedTitle
	}

	var trimPaddingBetweenArrowAndTitle: CGFloat {
		titleBarPopUpButtonCell.trimPaddingBetweenArrowAndTitle
	}

	override var intrinsicContentSize: NSSize {
		var newSize = super.intrinsicContentSize
		newSize.width += extraWidthForFormattedTitle - trimPaddingBetweenArrowAndTitle
		newSize.height += extraHeightForFormattedTitle
		return newSize
	}
}
