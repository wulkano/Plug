import Cocoa
import HypeMachineAPI

final class TagTableCellView: IOSStyleTableCellView {
	var nameTextField: NSTextField!

	override var objectValue: Any! {
		didSet {
			objectValueChanged()
		}
	}

	var tagValue: HypeMachineAPI.Tag { objectValue as! HypeMachineAPI.Tag }

	func objectValueChanged() {
		guard objectValue != nil else {
			return
		}

		updateName()
	}

	func updateName() {
		nameTextField.stringValue = tagValue.name
	}
}
