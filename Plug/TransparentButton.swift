import Cocoa

final class TransparentButton: NSButton {
	@IBInspectable var isSelectable: Bool = false
	@IBInspectable var selectedImage: NSImage?
	@IBInspectable var unselectedImage: NSImage?

	@IBInspectable var selectedOpacity: Double = 1
	@IBInspectable var mouseDownOpacity: Double = 1
	@IBInspectable var mouseInsideOpacity: Double = 0.7
	@IBInspectable var inactiveOpacity: Double = 0.3

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

	var isTemplated = false

	override func draw(_ dirtyRect: CGRect) {
		var drawPosition = bounds
		var drawImage = getDrawImage()

		if drawImage?.isTemplate == true {
			drawImage = drawImage?.tinted(color: .labelColor)
		}

		let drawOpacity = getDrawOpacity()

		if drawImage != nil {
			drawPosition.origin.x = (bounds.size.width - drawImage!.size.width) / 2
			drawPosition.origin.y = -(bounds.size.height - drawImage!.size.height) / 2
		}

		drawImage?.draw(
			in: drawPosition,
			from: bounds,
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
		if isSelectable, isSelected {
			return selectedImage
		}

		return unselectedImage
	}

	func getDrawOpacity() -> Double {
		if isSelectable, isSelected {
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
