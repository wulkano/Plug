import Cocoa

final class FlatSliderCell: NSSliderCell {
	@IBInspectable var barColor: NSColor = .tertiaryLabelColor
	@IBInspectable var barFillColor: NSColor = .labelColor
	@IBInspectable var knobSize: CGFloat = 12
	@IBInspectable var knobFillColor: NSColor = .labelColor // TODO: Fix this for dark mode.

	var isMouseDown = false
	var isMouseInside = false

	override func drawBar(inside aRect: CGRect, flipped: Bool) {
		let knobRect = self.knobRect(flipped: flipped)

		let inset: CGFloat = floor(knobRect.size.width / 2) // Floor so we don't end up on a 0.5 pixel and draw weird
		let knobCenterX = knobRect.origin.x + inset

		var barFillRect = aRect
		barFillRect.size.width = knobCenterX - inset
		barFillRect.origin.x = inset
		barFillColor.set()
		barFillRect.fill(using: .sourceOver)

		var barRect = aRect
		barRect.origin.x = knobCenterX
		barRect.size.width -= knobCenterX - inset + 2.5
		barColor.set()
		barRect.fill(using: .sourceOver)
	}

	override func drawKnob(_ knobRect: CGRect) {
//		  TODO: fix this drawing so it's not overlapping on the bar
//		  if isMouseInside {
//			  var vInset = (knobRect.size.height - knobSize) / 2
//			  var hInset = (knobRect.size.width - knobSize) / 2
//			  knobFillColor.set()
//			  let insetRect = NSInsetRect(knobRect, hInset, vInset)
//			  let circlePath = NSBezierPath(ovalInRect: insetRect)
//			  circlePath.fill()
//		  }
	}
}
