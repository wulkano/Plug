import Cocoa

// swiftlint:disable:next final_class
class SwissArmyButtonCell: NSButtonCell {
	var isMouseInside = false
	var isMouseDown = false

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		highlightsBy = []
	}

	override init(textCell aString: String) {
		super.init(textCell: aString)
		highlightsBy = []
	}
}
