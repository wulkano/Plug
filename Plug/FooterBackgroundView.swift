import Cocoa

final class FooterBackgroundView: DraggableVisualEffectsView {
	override func viewDidMoveToWindow() {
		addTrackingRect(bounds, owner: self, userData: nil, assumeInside: false)
	}

	override func mouseEntered(with theEvent: NSEvent) {}

	override func mouseExited(with theEvent: NSEvent) {}
}
