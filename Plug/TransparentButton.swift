import Cocoa

final class TransparentButton: NSButton {
	@IBInspectable var selectable: Bool = false
	@IBInspectable var selectedImage: NSImage?
	@IBInspectable var unselectedImage: NSImage?

	@IBInspectable var selectedOpacity: CGFloat = 1
	@IBInspectable var mouseDownOpacity: CGFloat = 1
	@IBInspectable var mouseInsideOpacity: CGFloat = 0.7
	@IBInspectable var inactiveOpacity: CGFloat = 0.3

	var isMouseInside: Bool = false {
		didSet {
			needsDisplay = true
		}
	}

	var isMouseDown: Bool = false {
		didSet {
			needsDisplay = true
		}
	}

	var isSelected: Bool = false {
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

		drawImage?.draw(in: drawPosition, from: dirtyRect, operation: NSCompositingOperation.sourceOver, fraction: drawOpacity, respectFlipped: true, hints: nil)
	}

	override func viewDidMoveToWindow() {
		addTrackingRect(bounds, owner: self, userData: nil, assumeInside: false)
	}

	func getDrawImage() -> NSImage? {
		if selectable && isSelected {
			return selectedImage
		} else {
			return unselectedImage
		}
	}

	func getDrawOpacity() -> CGFloat {
		if selectable && isSelected {
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
		if isSelected {
			isSelected = false
		} else {
			isSelected = true
		}
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
