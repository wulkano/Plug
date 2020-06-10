import Cocoa

final class GeneralPreferencesTableCellView: NSTableCellView {
	@IBOutlet private var preferenceTitle: NSTextField!
	@IBOutlet private var switchButton: IOSSwitch!

	override var objectValue: Any! {
		didSet {
			objectValueChanged()
		}
	}

	var generalPreferenceValue: GeneralPreference { objectValue as! GeneralPreference }

	func objectValueChanged() {
		guard objectValue != nil else {
			return
		}

		updatePreferenceTitle()
		updateSwitchButton()
	}

	func updatePreferenceTitle() {
		preferenceTitle.stringValue = generalPreferenceValue.title
	}

	func updateSwitchButton() {
		switchButton.on = generalPreferenceValue.getUserDefaultsValue()
	}

	@IBAction private func switchButtonClicked(_ sender: IOSSwitch) {
		let oldValue = generalPreferenceValue.getUserDefaultsValue()
		let newValue = !oldValue
		generalPreferenceValue.setUserDefaultsValue(newValue)
	}
}
