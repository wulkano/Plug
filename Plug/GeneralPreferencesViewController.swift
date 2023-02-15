import Cocoa

let showTrackChangeNotificationsKey = "ShowTrackChangeNotifications"
let enableMediaKeysKey = "EnableMediaKeysKey"
let hideUnavailableTracks = "HideUnavailableTracks"
let preventIdleSleepWhenPlaying = "PreventIdleSleepWhenPlaying"

final class GeneralPreferencesViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
	@IBOutlet private var scrollViewHeightContraint: NSLayoutConstraint!
	@IBOutlet private var tableView: NSTableView!

	var preferences: [GeneralPreference] = [
		GeneralPreference(title: "Show notifications when changing tracks", settingsKey: showTrackChangeNotificationsKey),
		GeneralPreference(title: "Hide tracks that are unavailable", settingsKey: hideUnavailableTracks),
		GeneralPreference(title: "Prevent sleep when playing music", settingsKey: preventIdleSleepWhenPlaying)
	]

	func setHeightForPreferences() {
		let desiredHeight = Double(preferences.count) * 80
		scrollViewHeightContraint.constant = desiredHeight
	}

	// MARK: NSViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		setHeightForPreferences()
	}

	// MARK: NSTableViewDelegate

	func selectionShouldChange(in tableView: NSTableView) -> Bool { false }

	func numberOfRows(in tableView: NSTableView) -> Int {
		preferences.count
	}

	// MARK: NSTableViewDataSource

	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
		preferences[row]
	}
}

// Only supports Bools for now
final class GeneralPreference {
	let title: String
	let settingsKey: String

	init(title: String, settingsKey: String) {
		self.title = title
		self.settingsKey = settingsKey
	}

	func getUserDefaultsValue() -> Bool {
		UserDefaults.standard.bool(forKey: settingsKey)
	}

	func setUserDefaultsValue(_ value: Bool) {
		UserDefaults.standard.setValue(value, forKey: settingsKey)
	}
}
