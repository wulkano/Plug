import Cocoa

final class LoginButtonCell: SwissArmyButtonCell {
	var loginButton: LoginButton {
		controlView as! LoginButton
	}

	override func drawTitle(_ title: NSAttributedString, withFrame frame: CGRect, in controlView: NSView) -> CGRect {
		let mutableTitle = NSMutableAttributedString(attributedString: title)
		let range = NSRange(location: 0, length: mutableTitle.length)
		let color = getTextColor()

		mutableTitle.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)

		return super.drawTitle(mutableTitle, withFrame: frame, in: controlView)
	}

	override func drawImage(_ image: NSImage, withFrame frame: CGRect, in controlView: NSView) {
		let alpha = getImageAlpha()

		var newFrame = frame
		newFrame.origin.y += 3

		image.draw(in: newFrame, from: CGRect.zero, operation: .sourceOver, fraction: alpha, respectFlipped: true, hints: nil)
	}

	func getTextColor() -> NSColor {
		switch loginButton.buttonState {
		case .error:
			return NSColor(red256: 255, green256: 95, blue256: 82).withAlphaComponent(getAlpha())
		default:
			return NSColor.white.withAlphaComponent(getAlpha())
		}
	}

	func getAlpha() -> CGFloat {
		switch loginButton.buttonState {
		case .enabled, .error:
			if isMouseDown {
				return 0.3
			} else if isMouseInside {
				return 0.6
			} else {
				return 1
			}
		case .disabled:
			return 0.5
		case .sending:
			return 1
		}
	}

	func getImageAlpha() -> CGFloat {
		switch loginButton.buttonState {
		case .sending, .disabled:
			return 0
		default:
			return getAlpha()
		}
	}
}
