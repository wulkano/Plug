import Cocoa

final class LoginButtonCell: SwissArmyButtonCell {
	var loginButton: LoginButton { controlView as! LoginButton }

	override func drawTitle(_ title: NSAttributedString, withFrame frame: CGRect, in controlView: NSView) -> CGRect {
		let mutableTitle = NSMutableAttributedString(attributedString: title)
		let range = NSRange(location: 0, length: mutableTitle.length)
		let color = getTextColor()

		mutableTitle.addAttribute(.foregroundColor, value: color, range: range)

		return super.drawTitle(mutableTitle, withFrame: frame, in: controlView)
	}

	override func drawImage(_ image: NSImage, withFrame frame: CGRect, in controlView: NSView) {
		let alpha = getImageAlpha()

		var newFrame = frame
		newFrame.origin.y += 3

		image.draw(in: newFrame, from: .zero, operation: .sourceOver, fraction: alpha, respectFlipped: true, hints: nil)
	}

	func getTextColor() -> NSColor {
		switch loginButton.buttonState {
		case .error:
			NSColor(red256: 255, green256: 95, blue256: 82).withAlphaComponent(getAlpha())
		default:
			.white.withAlphaComponent(getAlpha())
		}
	}

	func getAlpha() -> Double {
		switch loginButton.buttonState {
		case .enabled, .error:
			if isMouseDown {
				return 0.3
			}

			if isMouseInside {
				return 0.6
			}

			return 1
		case .disabled:
			return 0.5
		case .sending:
			return 1
		}
	}

	func getImageAlpha() -> Double {
		switch loginButton.buttonState {
		case .sending, .disabled:
			0
		default:
			getAlpha()
		}
	}
}
