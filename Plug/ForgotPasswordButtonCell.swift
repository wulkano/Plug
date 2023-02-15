import Cocoa

final class ForgotPasswordButtonCell: SwissArmyButtonCell {
	override func drawBezel(withFrame frame: CGRect, in controlView: NSView) {}

	override func drawTitle(_ title: NSAttributedString, withFrame frame: CGRect, in controlView: NSView) -> CGRect {
		let alpha: Double = if isMouseDown {
			1
		} else if isMouseInside {
			0.5
		} else {
			0.2
		}

		let mutableTitle = NSMutableAttributedString(attributedString: title)
		let color = NSColor.white.withAlphaComponent(alpha)
		let range = NSRange(location: 0, length: mutableTitle.length)

		mutableTitle.addAttribute(.foregroundColor, value: color, range: range)

		return super.drawTitle(mutableTitle, withFrame: frame, in: controlView)
	}
}
