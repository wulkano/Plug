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

		if #available(macOS 11, *) {
			aboutWindow.contentViewController = NSHostingController(rootView: AboutView())
		} else {
			aboutWindow.contentViewController = AboutViewController(nibName: nil, bundle: nil)
		}

		aboutWindow.center()

		self.init(window: aboutWindow)
	}
}
