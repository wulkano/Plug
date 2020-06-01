import Cocoa

final class SidebarOverlayView: NSView {
	let overlayColor = NSColor(red256: 91, green256: 91, blue256: 91)

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		initialSetup()
	}

	override init(frame frameRect: CGRect) {
		super.init(frame: frameRect)
		initialSetup()
	}

	deinit {
		Notifications.unsubscribeAll(observer: self)
	}

	func initialSetup() {
		Notifications.subscribe(observer: self, selector: #selector(SidebarOverlayView.windowStatusChanged), name: NSWindow.didBecomeMainNotification, object: nil)
		Notifications.subscribe(observer: self, selector: #selector(SidebarOverlayView.windowStatusChanged), name: NSWindow.didResignMainNotification, object: nil)
	}

	override func draw(_ dirtyRect: CGRect) {
		super.draw(dirtyRect)

		if
			let window = self.window,
			!window.isMainWindow
		{
			overlayColor.set()
			dirtyRect.fill()
		}
	}

	@objc
	func windowStatusChanged() {
		needsDisplay = true
	}
}
