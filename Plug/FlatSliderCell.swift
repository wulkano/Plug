import Cocoa

final class FlatSliderCell: NSSliderCell {
	@IBInspectable var barColor: NSColor = .tertiaryLabelColor
	@IBInspectable var barFillColor: NSColor = .labelColor

	override func drawBar(inside aRect: CGRect, flipped: Bool) {
		let knobRect = knobRect(flipped: flipped)
		let inset: CGFloat = floor(knobRect.size.width / 2) // Floor so we don't end up on a 0.5 pixel and draw weird
		let knobCenterX = knobRect.origin.x + inset

		var barFillRect = aRect
		barFillRect.size.width = knobCenterX - inset
		barFillRect.origin.x = inset
		barFillColor.set()
		barFillRect.fill(using: .sourceOver)

		var barRect = aRect
		barRect.origin.x = knobCenterX
		barRect.size.width -= knobCenterX - inset + 13
		barColor.set()
		barRect.fill(using: .sourceOver)
	}

	override func drawKnob(_ knobRect: CGRect) {}
}
