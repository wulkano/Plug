import Cocoa

final class IOSStyleTableRowView: NSTableRowView {
	override var isNextRowSelected: Bool {
		didSet {
			needsDisplay = true
		}
	}

	@IBInspectable var separatorSpacing: Double = 0
	@IBInspectable var customSeparatorColor: NSColor = .separatorColor
	@IBInspectable var selectionColor: NSColor = .quaternaryLabelColor

	let separatorWidth = 1.0
	var isNextRowGroupRow = false

	override func draw(_ dirtyRect: CGRect) {
		super.draw(dirtyRect)

		if shouldDrawSeparator {
			let separatorRect = makeSeparatorRect(dirtyRect)
			customSeparatorColor.set()
			separatorRect.fill()
		}
	}

	// MARK: Separator
	// Had to disable default separator behavior, otherwise empty
	// row views drew the incorrect default separator
//	  override func drawSeparatorInRect(dirtyRect: CGRect) {
//		  if shouldDrawSeparator() {
//			  let separatorRect = makeSeparatorRect(dirtyRect)
//			  customSeparatorColor.set()
//			  CGRectFill(separatorRect)
//		  }
//	  }

	private var shouldDrawSeparator: Bool {
		if isNextRowGroupRow {
			return true
		}

		if isSelected {
			return false
		}

		if isNextRowSelected {
			return false
		}

		return true
	}

	func makeSeparatorRect(_ dirtyRect: CGRect) -> CGRect {
		var separatorRect = bounds
		separatorRect.size.height = separatorWidth

		if !isNextRowGroupRow {
			separatorRect.size.width = bounds.size.width - separatorSpacing
			separatorRect.origin.x = separatorSpacing
		}

		separatorRect.origin.y = bounds.size.height - separatorWidth
		return separatorRect.intersection(dirtyRect)
	}

	// MARK: Selection

	override func drawSelection(in dirtyRect: CGRect) {
		let selectionRect = bounds
		selectionColor.set()
		selectionRect.fill()
	}
}
