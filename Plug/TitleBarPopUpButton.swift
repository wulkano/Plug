import Cocoa

final class TitleBarPopUpButton: NSPopUpButton {
	var titleBarPopUpButtonCell: TitleBarPopUpButtonCell { cell as! TitleBarPopUpButtonCell }

	var formattedTitle: NSAttributedString {
		titleBarPopUpButtonCell.formattedTitle
	}

	var extraWidthForFormattedTitle: Double {
		titleBarPopUpButtonCell.extraWidthForFormattedTitle
	}

	var extraHeightForFormattedTitle: Double {
		titleBarPopUpButtonCell.extraHeightForFormattedTitle
	}

	var trimPaddingBetweenArrowAndTitle: Double {
		titleBarPopUpButtonCell.trimPaddingBetweenArrowAndTitle
	}

	override var intrinsicContentSize: CGSize {
		var newSize = super.intrinsicContentSize
		newSize.width += extraWidthForFormattedTitle - trimPaddingBetweenArrowAndTitle + 1
		newSize.height += extraHeightForFormattedTitle
		return newSize
	}
}
