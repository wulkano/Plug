import Cocoa

final class PreferencesWindowController: NSWindowController {
	override func windowDidLoad() {
		super.windowDidLoad()

		window!.titleVisibility = .visible
		window!.styleMask = [
			.titled,
			.closable,
			.fullSizeContentView
		]
	}
}
