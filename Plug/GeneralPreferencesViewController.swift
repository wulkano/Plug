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

class GeneralPreferencesViewController: NSViewController, NSTableViewDelegate {
    @IBOutlet weak var scrollViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: NSTableView!
    
    var preferences: [GeneralPreference] = [
        GeneralPreference(title: "Show notification when changing tracks", settingsKey: ShowTrackChangeNotificationsKey),
        GeneralPreference(title: "Use media keys for shortcuts", settingsKey: EnableMediaKeysKey),
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
    func selectionShouldChangeInTableView(tableView: NSTableView!) -> Bool {
        return false
    }
}

// Only supports Bools for now
class GeneralPreference: NSObject {
    var title: String
    var settingsKey: String
    
    init(title: String, settingsKey: String) {
        self.title = title
        self.settingsKey = settingsKey
        super.init()
    }
    
    func getUserDefaultsValue() -> Bool {
        return NSUserDefaults.standardUserDefaults().valueForKey(settingsKey) as Bool
    }
    
    func setUserDefaultsValue(value: Bool) {
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: settingsKey)
    }
}