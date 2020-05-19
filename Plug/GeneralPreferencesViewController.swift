//
//	GeneralPreferencesViewController.swift
//	Plug
//
//	Created by Alex Marchant on 8/25/14.
//	Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

let ShowTrackChangeNotificationsKey = "ShowTrackChangeNotifications"
let EnableMediaKeysKey = "EnableMediaKeysKey"
let HideUnavailableTracks = "HideUnavailableTracks"
let PreventIdleSleepWhenPlaying = "PreventIdleSleepWhenPlaying"

class GeneralPreferencesViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
	@IBOutlet var scrollViewHeightContraint: NSLayoutConstraint!
	@IBOutlet var tableView: NSTableView!

	var preferences: [GeneralPreference] = [
		GeneralPreference(title: "Show notifications when changing tracks", settingsKey: ShowTrackChangeNotificationsKey),
		GeneralPreference(title: "Hide tracks that are unavailable", settingsKey: HideUnavailableTracks),
		GeneralPreference(title: "Prevent sleep when playing music", settingsKey: PreventIdleSleepWhenPlaying)
	]

	func setHeightForPreferences() {
		let desiredHeight = CGFloat(preferences.count) * 70
		scrollViewHeightContraint.constant = desiredHeight
	}

	// MARK: NSViewController

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.

		setHeightForPreferences()
	}

	// MARK: NSTableViewDelegate

	func selectionShouldChange(in tableView: NSTableView) -> Bool {
		false // Disallows row selection
	}

	func numberOfRows(in tableView: NSTableView) -> Int {
		preferences.count
	}

	// MARK: NSTableViewDataSource

	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
		preferences[row]
	}
}

// Only supports Bools for now
class GeneralPreference {
	var title: String
	var settingsKey: String

	init(title: String, settingsKey: String) {
		self.title = title
		self.settingsKey = settingsKey
	}

	func getUserDefaultsValue() -> Bool {
		UserDefaults.standard.value(forKey: settingsKey) as! Bool
	}

	func setUserDefaultsValue(_ value: Bool) {
		UserDefaults.standard.setValue(value, forKey: settingsKey)
	}
}
