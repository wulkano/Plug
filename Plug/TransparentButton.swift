import Cocoa

final class TransparentButton: NSButton {
	@IBInspectable var isSelectable = false
	@IBInspectable var selectedImage: NSImage?
	@IBInspectable var unselectedImage: NSImage?

	@IBInspectable var selectedOpacity: CGFloat = 1
	@IBInspectable var mouseDownOpacity: CGFloat = 1
	@IBInspectable var mouseInsideOpacity: CGFloat = 0.7
	@IBInspectable var inactiveOpacity: CGFloat = 0.3

	var isMouseInside = false {
		didSet {
			needsDisplay = true
		}
	}

	var isMouseDown = false {
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
		var drawPosition = bounds
		let drawImage = getDrawImage()
		let drawOpacity = getDrawOpacity()

		if drawImage != nil {
			drawPosition.origin.x = (bounds.size.width - drawImage!.size.width) / 2
			drawPosition.origin.y = -(bounds.size.height - drawImage!.size.height) / 2
		}

		drawImage?.draw(
			in: drawPosition,
			from: dirtyRect,
			operation: .sourceOver,
			fraction: drawOpacity,
			respectFlipped: true,
			hints: nil
		)
	}

	override func viewDidMoveToWindow() {
		addTrackingRect(bounds, owner: self, userData: nil, assumeInside: false)
	}

	func getDrawImage() -> NSImage? {
		if isSelectable && isSelected {
			return selectedImage
		} else {
			return unselectedImage
		}
	}

	func getDrawOpacity() -> CGFloat {
		if isSelectable && isSelected {
			return selectedOpacity
		} else if isMouseDown {
			return mouseDownOpacity
		} else if isMouseInside {
			return mouseInsideOpacity
		} else {
			return inactiveOpacity
		}
	}

	func toggleSelected() {
		isSelected.toggle()
	}

	override func mouseDown(with theEvent: NSEvent) {
		isMouseDown = true
		super.mouseDown(with: theEvent)
		mouseUp(with: theEvent)
	}

	override func mouseUp(with theEvent: NSEvent) {
		isMouseDown = false
		super.mouseUp(with: theEvent)
	}

	override func mouseEntered(with theEvent: NSEvent) {
		isMouseInside = true
	}

	override func mouseExited(with theEvent: NSEvent) {
		isMouseInside = false
	}
}
