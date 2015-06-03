//
//  GeneralPreferencesViewController.swift
//  Plug
//
//  Created by Alex Marchant on 8/25/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

let ShowTrackChangeNotificationsKey = "ShowTrackChangeNotifications"
let EnableMediaKeysKey = "EnableMediaKeysKey"
let HideUnavailableTracks = "HideUnavailableTracks"

class GeneralPreferencesViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet weak var scrollViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: NSTableView!
    
    var preferences: [GeneralPreference] = [
        GeneralPreference(title: "Show notifications when changing tracks", settingsKey: ShowTrackChangeNotificationsKey),
        GeneralPreference(title: "Hide tracks that are unavailable", settingsKey: HideUnavailableTracks),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        setHeightForPreferences()
    }
    
    func setHeightForPreferences() {
        var desiredHeight = CGFloat(preferences.count) * 70
        scrollViewHeightContraint.constant = desiredHeight
    }
    
    // Disallows row selection
    func selectionShouldChangeInTableView(tableView: NSTableView) -> Bool {
        return false
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return preferences[row]
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return preferences.count
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
        return NSUserDefaults.standardUserDefaults().valueForKey(settingsKey) as! Bool
    }

    func setUserDefaultsValue(value: Bool) {
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: settingsKey)
    }
}