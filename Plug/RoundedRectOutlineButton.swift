import Cocoa

final class RoundedRectOutlineButton: NSButton {
	@IBInspectable var radius: CGFloat = 3
	@IBInspectable var strokeWidth: CGFloat = 1
	@IBInspectable var strokeColor: NSColor = .white

	override func draw(_ dirtyRect: CGRect) {
		super.draw(dirtyRect)

		let rect = CGRect(x: 0.5, y: 0.5, width: bounds.size.width - 1, height: bounds.size.height - 1)
		let roundedRect = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
		roundedRect.lineWidth = strokeWidth
		strokeColor.set()
		roundedRect.stroke()
	}
}
