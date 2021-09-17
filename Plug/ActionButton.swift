import Cocoa

final class ActionButton: SwissArmyButton {
	private var actionButtonCell: ActionButtonCell { cell as! ActionButtonCell }

	var horizontalPadding: Double { actionButtonCell.horizontalPadding }

	var offStateTitle: String {
		get { actionButtonCell.offStateTitle }
		set {
			actionButtonCell.offStateTitle = newValue
		}
	}

	var onStateTitle: String {
		get { actionButtonCell.onStateTitle }
		set {
			actionButtonCell.onStateTitle = newValue
		}
	}

	override var intrinsicContentSize: CGSize {
		var newSize = super.intrinsicContentSize
		newSize.width += horizontalPadding
		return newSize
	}
}
