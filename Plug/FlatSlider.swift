import Cocoa

final class FlatSlider: NSSlider {
	override var doubleValue: Double {
		get {
			super.doubleValue
		}
		set {
			if !isMouseDown {
				super.doubleValue = newValue
			}
		}
	}

	private var flatSliderCell: FlatSliderCell { cell as! FlatSliderCell }

	private var isMouseDown: Bool {
		get { flatSliderCell.isMouseDown }
		set {
			flatSliderCell.isMouseDown = newValue
		}
	}

	private var isMouseInside: Bool {
		get { flatSliderCell.isMouseInside }
		set {
			flatSliderCell.isMouseInside = newValue
		}
	}

	override func viewDidMoveToWindow() {
		addTrackingRect(bounds, owner: self, userData: nil, assumeInside: false)
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
		needsDisplay = true
	}

	override func mouseExited(with theEvent: NSEvent) {
		isMouseInside = false
		needsDisplay = true
	}
}
