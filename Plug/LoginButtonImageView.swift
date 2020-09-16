import Cocoa

final class LoginButtonImageView: NSImageView {
	override var allowsVibrancy: Bool { true }

	private var alpha: CGFloat = 1

	override func draw(_ dirtyRect: CGRect) {
		guard let image = image else {
			return
		}

		image.draw(in: dirtyRect, from: .zero, operation: .sourceOver, fraction: alpha)
	}
}
