import Cocoa

class SwissArmyButtonCell: NSButtonCell {
	var isMouseInside: Bool = false
	var isMouseDown: Bool = false

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		highlightsBy = NSCell.StyleMask()
	}

	override init(textCell aString: String) {
		super.init(textCell: aString)
		highlightsBy = NSCell.StyleMask()
	}
}
