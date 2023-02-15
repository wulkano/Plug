import Cocoa

final class BackgroundBorderView: NSView {
	@IBInspectable var borderWidth: Double = 1
	@IBInspectable var topBorder: Bool = false
	@IBInspectable var rightBorder: Bool = false
	@IBInspectable var bottomBorder: Bool = false
	@IBInspectable var leftBorder: Bool = false

	@IBInspectable var borderColor: NSColor = .borderColor {
		didSet {
			needsDisplay = true
		}
	}

	@IBInspectable var hasBackground: Bool = false
	@IBInspectable var backgroundColor: NSColor = .clear {
		didSet {
			needsDisplay = true
		}
	}

	override func draw(_ dirtyRect: CGRect) {
		super.draw(dirtyRect)
		drawBackground(dirtyRect)
		drawBorder(dirtyRect)
	}

	func drawBackground(_ dirtyRect: CGRect) {
		if hasBackground {
			backgroundColor.set()
			bounds.fill(using: .sourceOver)
		}
	}

	func drawBorder(_ dirtyRect: CGRect) {
		borderColor.set()

		if topBorder {
			var topRect = bounds
			topRect.size.height = borderWidth
			topRect.origin.y = bounds.size.height - borderWidth
			topRect.intersection(bounds).fill(using: .sourceOver)
		}

		if rightBorder {
			var rightRect = bounds
			rightRect.size.width = borderWidth
			rightRect.origin.x = bounds.size.width - borderWidth
			rightRect.intersection(bounds).fill(using: .sourceOver)
		}

		if bottomBorder {
			var bottomRect = bounds
			bottomRect.size.height = borderWidth
			bottomRect.intersection(bounds).fill(using: .sourceOver)
		}

		if leftBorder {
			var leftRect = bounds
			leftRect.size.width = borderWidth
			leftRect.intersection(bounds).fill(using: .sourceOver)
		}
	}
}
