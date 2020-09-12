import Cocoa

final class GroupRowView: NSTableRowView {
	let backgroundFill = NSColor.controlBackgroundColor
	let lineFill = NSColor.borderColor

	override func draw(_ dirtyRect: CGRect) {
		drawBackground(dirtyRect)
		drawSeparators(dirtyRect)
	}

	func drawBackground(_ dirtyRect: CGRect) {
		backgroundFill.set()
		dirtyRect.fill()
	}

	func drawSeparators(_ dirtyRect: CGRect) {
		var bottomSeparatorRect = bounds
		bottomSeparatorRect.origin.y = bounds.size.height - 1
		bottomSeparatorRect.size.height = 1

		lineFill.set()
		bottomSeparatorRect.intersection(dirtyRect).fill()
	}
}
