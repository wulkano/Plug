import Cocoa

final class TagButtonCell: SwissArmyButtonCell {
	var fillColor = NSColor.clear

	override func drawBezel(withFrame frame: CGRect, in controlView: NSView) {
		let rect = frame.insetBy(dx: 1, dy: 1)
		let roundedRect = NSBezierPath(roundedRect: rect, xRadius: 3, yRadius: 3)
		roundedRect.lineWidth = 0
		fillColor.setFill()
		roundedRect.fill()
	}

	override func drawTitle(_ title: NSAttributedString, withFrame frame: CGRect, in controlView: NSView) -> CGRect {
		var newFrame = frame
		newFrame.origin.x -= 4.5
		newFrame.size.width += 9
		return super.drawTitle(title, withFrame: newFrame, in: controlView)
	}

	override func cellSize(forBounds aRect: CGRect) -> CGSize {
		var size = super.cellSize(forBounds: aRect)
		size.width += 6
		return size
	}
}
