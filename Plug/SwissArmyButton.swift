import Cocoa

class SwissArmyButton: NSButton {
	@IBInspectable var isVibrant = false
	@IBInspectable var isTrackingHover = false

	override var allowsVibrancy: Bool { isVibrant }

	@objc override dynamic var state: NSControl.StateValue {
		didSet {
			needsDisplay = true
		}
	}

	var trackingArea: NSTrackingArea?
	var swissArmyButtonCell: SwissArmyButtonCell { cell as! SwissArmyButtonCell }

	var isMouseInside: Bool {
		get { swissArmyButtonCell.isMouseInside }
		set {
			swissArmyButtonCell.isMouseInside = newValue
		}
	}

	var isMouseDown: Bool {
		get { swissArmyButtonCell.isMouseDown }
		set {
			swissArmyButtonCell.isMouseDown = newValue
		}
	}

	override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()

		updateTrackingAreas()
	}

	override func updateTrackingAreas() {
		super.updateTrackingAreas()

		if isTrackingHover {
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
	}

	override init(frame frameRect: CGRect) {
		super.init(frame: frameRect)
		setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	func setup() {
		setupCell()

		isBordered = false
	}

	func setupCell() {
		let newCell = SwissArmyButtonCell(textCell: "")
		cell = newCell
	}

	override func mouseEntered(with theEvent: NSEvent) {
		isMouseInside = true
		needsDisplay = true
	}

	override func mouseExited(with theEvent: NSEvent) {
		isMouseInside = false
		needsDisplay = true
	}

	override func mouseDown(with theEvent: NSEvent) {
		isMouseDown = true
		needsDisplay = true
		super.mouseDown(with: theEvent)
		mouseUp(with: theEvent)
	}

	override func mouseUp(with theEvent: NSEvent) {
		isMouseDown = false
		needsDisplay = true
		super.mouseUp(with: theEvent)
	}
}
