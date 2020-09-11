import Cocoa

final class TransparentButtonCell: SwissArmyButtonCell {
	@IBInspectable var allowsSelectedState: Bool = false

	let selectedOpacity: CGFloat = 1
	let mouseDownOpacity: CGFloat = 1
	let mouseInsideOpacity: CGFloat = 0.8
	let inactiveOpacity: CGFloat = 0.4

	var isTemplated = false

	override func drawImage(_ image: NSImage, withFrame frame: CGRect, in controlView: NSView) {
		let alpha = getImageAlpha()

		// TODO: Handle shuffle which should be red. Use tinting instead of separate image.
		if var drawImage = getDrawImage() {
			if isTemplated {
				drawImage = drawImage.tinted(color: .labelColor)
			}

			drawImage.draw(in: frame, from: .zero, operation: .sourceOver, fraction: alpha, respectFlipped: true, hints: nil)
		}
	}

	func getImageAlpha() -> CGFloat {
		if allowsSelectedState, state == .on {
			return selectedOpacity
		} else if isMouseDown {
			return mouseDownOpacity
		} else if isMouseInside {
			return mouseInsideOpacity
		} else {
			return inactiveOpacity
		}
	}

	func getDrawImage() -> NSImage? {
		if allowsSelectedState, state == .on {
			return alternateImage ?? image
		} else if isMouseDown {
			return image
		} else if isMouseInside {
			return image
		} else {
			return image
		}
	}
}
