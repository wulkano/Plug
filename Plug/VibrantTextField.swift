import Cocoa

final class VibrantTextField: NSTextField {
	override var allowsVibrancy: Bool { true }

	override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()
		setupStyledPlaceholderString()
	}

	func setupStyledPlaceholderString() {
		guard let placeholderString = placeholderString else {
			return
		}

		let newAttributedPlaceholderString = NSMutableAttributedString(string: placeholderString, attributes: placeholderAttributes())
		placeholderAttributedString = newAttributedPlaceholderString
	}

	func placeholderAttributes() -> [NSAttributedString.Key: Any] {
		var attributes = [NSAttributedString.Key: Any]()
		attributes[.foregroundColor] = NSColor.white.withAlphaComponent(0.2)
		attributes[.font] = (cell as! NSTextFieldCell).font
		return attributes
	}
}
