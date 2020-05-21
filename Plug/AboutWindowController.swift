import Cocoa

final class AboutWindowController: NSWindowController {
	convenience init() {
		let aboutWindow = NSWindow(
			contentRect: .zero,
			styleMask: [
				.titled,
				.closable
			],
			backing: .buffered,
			defer: false
		)
		aboutWindow.contentViewController = AboutViewController(nibName: nil, bundle: nil)
		aboutWindow.center()

		self.init(window: aboutWindow)
	}
}
