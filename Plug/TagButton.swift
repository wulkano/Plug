import Cocoa

final class TagButton: SwissArmyButton {
	var fillColor: NSColor {
		get { tagButtonCell.fillColor }
		set {
			tagButtonCell.fillColor = newValue
		}
	}

	override var title: String {
		get { attributedTitle.string }
		set {
			attributedTitle = NSAttributedString(string: newValue)
		}
	}

	override var attributedTitle: NSAttributedString {
		get { super.attributedTitle }
		set {
			super.attributedTitle = NSAttributedString(string: newValue.string, attributes: fontAttributes())
		}
	}

	var tagButtonCell: TagButtonCell { cell as! TagButtonCell }

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	override init(frame frameRect: CGRect) {
		super.init(frame: frameRect)
		setupCell()
		setButtonType(NSButton.ButtonType.momentaryPushIn)
		bezelStyle = NSButton.BezelStyle.regularSquare
	}

	override func setupCell() {
		let newCell = TagButtonCell(textCell: "")
		cell = newCell
	}

	func fontAttributes() -> [NSAttributedString.Key: Any] {
		var attributes = [NSAttributedString.Key: Any]()
		let color = NSColor.black
		let font = appFont(size: 12, weight: .bold)
		attributes[.foregroundColor] = color
		attributes[.font] = font
		return attributes
	}
}
