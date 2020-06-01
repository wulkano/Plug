import Cocoa

final class BackgroundBorderView: NSView {
	@IBInspectable var borderWidth: CGFloat = 1
	@IBInspectable var topBorder = false
	@IBInspectable var rightBorder = false
	@IBInspectable var bottomBorder = false
	@IBInspectable var leftBorder = false
	@IBInspectable var borderColor: NSColor = .black

	@IBInspectable var hasBackground: Bool = false
	@IBInspectable var backgroundColor: NSColor = .white {
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
			dirtyRect.fill(using: .sourceOver)
		}
	}

	func drawBorder(_ dirtyRect: CGRect) {
		borderColor.set()

		if topBorder {
			var topRect = bounds
			topRect.size.height = borderWidth
			topRect.origin.y = bounds.size.height - borderWidth
			topRect.intersection(dirtyRect).fill(using: .sourceOver)
		}

		if rightBorder {
			var rightRect = bounds
			rightRect.size.width = borderWidth
			rightRect.origin.x = bounds.size.width - borderWidth
			rightRect.intersection(dirtyRect).fill(using: .sourceOver)
		}

		if bottomBorder {
			var bottomRect = bounds
			bottomRect.size.height = borderWidth
			bottomRect.intersection(dirtyRect).fill(using: .sourceOver)
		}

		if leftBorder {
			var leftRect = bounds
			leftRect.size.width = borderWidth
			leftRect.intersection(dirtyRect).fill(using: .sourceOver)
		}
	}
}
