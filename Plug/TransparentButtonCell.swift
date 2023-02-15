import Cocoa

final class TransparentButtonCell: SwissArmyButtonCell {
	@IBInspectable var allowsSelectedState: Bool = false

	let selectedOpacity = 1.0
	let mouseDownOpacity = 1.0
	let mouseInsideOpacity = 0.8
	let inactiveOpacity = 0.4

	override func drawImage(_ image: NSImage, withFrame frame: CGRect, in controlView: NSView) {
		let alpha = getImageAlpha()

		// TODO: Handle shuffle which should be red. Use tinting instead of separate image.
		if var drawImage = getDrawImage() {
			if drawImage.isTemplate {
				drawImage = drawImage.tinted(color: .labelColor)
			}

			drawImage.draw(in: frame, from: .zero, operation: .sourceOver, fraction: alpha, respectFlipped: true, hints: nil)
		}
	}

	func getImageAlpha() -> Double {
		if allowsSelectedState, state == .on {
			return selectedOpacity
		}

		if isMouseDown {
			return mouseDownOpacity
		}

		if isMouseInside {
			return mouseInsideOpacity
		}

		return inactiveOpacity
	}

	func getDrawImage() -> NSImage? {
		if allowsSelectedState, state == .on {
			return alternateImage ?? image
		}

		if isMouseDown {
			return image
		}

		if isMouseInside {
			return image
		}

		return image
	}
}
