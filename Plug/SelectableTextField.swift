import Cocoa

final class SelectableTextField: NSTextField {
	@IBInspectable var isSelected = false {
		didSet {
			if isSelected {
				defaultTextColor = textColor
				textColor = selectedTextColor
			} else {
				if defaultTextColor != nil {
					textColor = defaultTextColor
				}
			}
		}
	}

	@IBInspectable var selectedTextColor: NSColor = NSColor(red256: 255, green256: 95, blue256: 82)
	var defaultTextColor: NSColor?
}
