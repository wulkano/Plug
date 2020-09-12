import Cocoa

final class HiddenTitlebarWindow: NSWindow {
	override init(contentRect: CGRect, styleMask aStyle: NSWindow.StyleMask, backing bufferingType: NSWindow.BackingStoreType, defer flag: Bool) {
		super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag)

		setup()
	}

	func setup() {
		styleMask = [styleMask, NSWindow.StyleMask.fullSizeContentView]
		titleVisibility = NSWindow.TitleVisibility.hidden
		titlebarAppearsTransparent = true
		isMovableByWindowBackground = true
	}
}
