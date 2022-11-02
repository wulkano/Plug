import Cocoa

final class BlogImageView: NSImageView {
	private var sideLength: Double { image!.size.width }
	private var halfSideLength: Double { sideLength / 2 }

	override func draw(_ dirtyRect: CGRect) {
		guard let image else {
			return
		}

		NSGraphicsContext.saveGraphicsState()

		let imageRect = calulateImageRect()
		let clippingRect = calculateClippingRect()
		let path = NSBezierPath(roundedRect: clippingRect, xRadius: halfSideLength, yRadius: halfSideLength)
		path.addClip()

		image.draw(in: bounds, from: imageRect, operation: .sourceOver, fraction: 1)

		NSGraphicsContext.restoreGraphicsState()
	}

	private func calulateImageRect() -> CGRect {
		var rect = CGRect.zero
		let croppedHeight = image!.size.height / 1.333_33

		rect.origin.x = 0
		rect.origin.y = image!.size.height - croppedHeight
		rect.size.width = image!.size.width
		rect.size.height = croppedHeight

		return rect
	}

	private func calculateClippingRect() -> CGRect {
		var rect = CGRect.zero
		let veritcalOffset = -(frame.size.width - frame.size.height) / 2

		rect.origin.x = 0
		rect.origin.y = veritcalOffset
		rect.size.width = sideLength
		rect.size.height = sideLength

		return rect
	}
}
