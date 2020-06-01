import Cocoa

final class ColoredTitleButton: NSButton {
	@IBInspectable var textColor: NSColor = .white {
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
		let range = NSRange(location: 0, length: textToStyle.length)
		textToStyle.addAttribute(.foregroundColor, value: textColor, range: range)
	}
}
