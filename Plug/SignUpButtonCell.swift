import Cocoa

final class SignUpButtonCell: SwissArmyButtonCell {
	override func drawBezel(withFrame frame: CGRect, in controlView: NSView) {
		let alpha: Double
		if isMouseDown {
			alpha = 1
		} else if isMouseInside {
			alpha = 0.5
		} else {
			alpha = 0.15
		}

		let radius = 3.0
		let strokeWidth = 1.0
		let strokeColor = NSColor.white.withAlphaComponent(alpha)

		let rect = CGRect(x: 0.5, y: 0.5, width: frame.size.width - 1, height: frame.size.height - 1)
		let roundedRect = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
		roundedRect.lineWidth = strokeWidth
		strokeColor.set()
		roundedRect.stroke()
	}

	override func drawTitle(_ title: NSAttributedString, withFrame frame: CGRect, in controlView: NSView) -> CGRect {
		let alpha: Double
		if isMouseDown {
			alpha = 1
		} else if isMouseInside {
			alpha = 0.8
		} else {
			alpha = 0.5
		}

		let mutableTitle = NSMutableAttributedString(attributedString: title)
		let color = NSColor.white.withAlphaComponent(alpha)
		let range = NSRange(location: 0, length: mutableTitle.length)

		mutableTitle.addAttribute(.foregroundColor, value: color, range: range)

		return super.drawTitle(mutableTitle, withFrame: frame, in: controlView)
	}
}
