import Cocoa

final class HoverToggleButton: NSButton {
	@IBInspectable var onImage: NSImage?
	@IBInspectable var onHoverImage: NSImage?
	@IBInspectable var offImage: NSImage?
	@IBInspectable var offHoverImage: NSImage?

	var trackingArea: NSTrackingArea?

	var isMouseInside = false {
		didSet {
			needsDisplay = true
		}
	}

	var isSelected = false {
		didSet {
			needsDisplay = true
		}
	}

	override func draw(_ dirtyRect: CGRect) {
		let drawImage = getDrawImage()

		var drawPosition = bounds
		if drawImage != nil {
			drawPosition.origin.x = (bounds.size.width - drawImage!.size.width) / 2
			drawPosition.origin.y = -(bounds.size.height - drawImage!.size.height) / 2
		}

		drawImage?.draw(
			in: drawPosition,
			from: dirtyRect,
			operation: .sourceOver,
			fraction: 1,
			respectFlipped: true,
			hints: nil
		)
	}

	func getDrawImage() -> NSImage? {
		if isSelected, isMouseInside {
			return onHoverImage
		} else if isSelected {
			return onImage
		} else if isMouseInside {
			return offHoverImage
		} else {
			return offImage
		}
	}

	override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()

		updateTrackingAreas()
	}

	override func updateTrackingAreas() {
		super.updateTrackingAreas()

		if trackingArea != nil {
			removeTrackingArea(trackingArea!)
			trackingArea = nil
		}

		let options: NSTrackingArea.Options = [
			.inVisibleRect,
			.activeAlways,
			.mouseEnteredAndExited
		]
		trackingArea = NSTrackingArea(rect: .zero, options: options, owner: self, userInfo: nil)
		addTrackingArea(trackingArea!)
	}

	override func mouseEntered(with theEvent: NSEvent) {
		isMouseInside = true
	}

	override func mouseExited(with theEvent: NSEvent) {
		isMouseInside = false
	}
}
