import Cocoa

final class SectionHeaderTableCellView: NSTableCellView {
	var titleTextField: NSTextField!

	override var objectValue: Any! {
		didSet {
			objectValueChanged()
		}
	}

	var sectionHeader: SectionHeader { objectValue as! SectionHeader }

	func objectValueChanged() {
		guard objectValue != nil else {
			return
		}

		updateTitle()
	}

	func updateTitle() {
		titleTextField?.stringValue = sectionHeader.title
	}
}
