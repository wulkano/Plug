import Cocoa

final class TitleBarPopUpButton: NSPopUpButton {
	var titleBarPopUpButtonCell: TitleBarPopUpButtonCell { cell as! TitleBarPopUpButtonCell }

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

	override var intrinsicContentSize: CGSize {
		var newSize = super.intrinsicContentSize
		newSize.width += extraWidthForFormattedTitle - trimPaddingBetweenArrowAndTitle + 1
		newSize.height += extraHeightForFormattedTitle
		return newSize
	}
}
