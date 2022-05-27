import SwiftUI

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

		aboutWindow.contentViewController = NSHostingController(rootView: AboutView())
		aboutWindow.center()

		self.init(window: aboutWindow)
	}
}
