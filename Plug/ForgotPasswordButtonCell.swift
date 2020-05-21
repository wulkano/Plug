import Cocoa

final class ForgotPasswordButtonCell: SwissArmyButtonCell {
	override func drawBezel(withFrame frame: CGRect, in controlView: NSView) {}

	override func drawTitle(_ title: NSAttributedString, withFrame frame: CGRect, in controlView: NSView) -> CGRect {
		var alpha: CGFloat

		if isMouseDown {
			alpha = 1
		} else if isMouseInside {
			alpha = 0.5
		} else {
			alpha = 0.2
		}

		let mutableTitle = NSMutableAttributedString(attributedString: title)
		let color = NSColor.white.withAlphaComponent(alpha)
		let range = NSRange(location: 0, length: mutableTitle.length)

		mutableTitle.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)

		return super.drawTitle(mutableTitle, withFrame: frame, in: controlView)
	}
}
