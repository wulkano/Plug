import Cocoa

final class ActionButton: SwissArmyButton {
	var actionButtonCell: ActionButtonCell {
		cell as! ActionButtonCell
	}

	var horizontalPadding: CGFloat {
		actionButtonCell.horizontalPadding
	}

	var offStateTitle: String {
		set { actionButtonCell.offStateTitle = newValue }
		get { actionButtonCell.offStateTitle }
	}

	var onStateTitle: String {
		set { actionButtonCell.onStateTitle = newValue }
		get { actionButtonCell.onStateTitle }
	}

	override var intrinsicContentSize: CGSize {
		var newSize = super.intrinsicContentSize
		newSize.width += horizontalPadding
		return newSize
	}
}
