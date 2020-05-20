import Cocoa

class IOSStyleTableCellView: NSTableCellView {
	override var backgroundStyle: NSView.BackgroundStyle {
		get { .light }
		set {}
	}
}
