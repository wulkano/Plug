import Cocoa

final class CircleMaskImageView: NSImageView {
	override func draw(_ dirtyRect: CGRect) {
		guard let image else {
			return
		}

		NSGraphicsContext.saveGraphicsState()

		let path = NSBezierPath(roundedRect: bounds, xRadius: bounds.size.width / 2, yRadius: bounds.size.height / 2)
		path.addClip()
		image.draw(in: bounds, from: .zero, operation: .sourceOver, fraction: 1)

		NSGraphicsContext.restoreGraphicsState()
	}
}
