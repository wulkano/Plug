import Cocoa

final class LoginButtonImageView: NSImageView {
	override var allowsVibrancy: Bool { true }

	private var alpha = 1.0

	override func draw(_ dirtyRect: CGRect) {
		guard let image else {
			return
		}

		image.draw(in: bounds, from: .zero, operation: .sourceOver, fraction: alpha)
	}
}
