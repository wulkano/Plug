//
//  PreferencesViewController.swift
//  Plug
//
//  Created by Alex Marchant on 8/25/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {
    @IBOutlet weak var generalTab: NSButton!
    @IBOutlet weak var hotkeysTab: NSButton!
    @IBOutlet weak var mutedTab: NSButton!
    var tabViewController: NSTabViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        Analytics.trackView("PreferencesWindow/General")
    }

    func toggleAllTabsExcept(_ sender: NSButton) {
        let allTabs = [
            generalTab,
            hotkeysTab,
            mutedTab
        ]
        for tab in allTabs {
            if tab === sender {
				tab?.state = .on
            } else {
				tab?.state = .off
            }
        }
    }

    func switchToTabAtIndex(_ index: Int) {
        ensureTabViewController()
        tabViewController.selectedTabViewItemIndex = index
    }

    func ensureTabViewController() {
        if tabViewController != nil { return }

		for controller in children {
            if controller is NSTabViewController {
                tabViewController = controller as? NSTabViewController
            }
        }
    }

    // MARK: Actions

    @IBAction func generalTabClicked(_ sender: NSButton) {
        Analytics.trackView("PreferencesWindow/General")
        toggleAllTabsExcept(sender)
        switchToTabAtIndex(0)
    }

    @IBAction func hotkeysTabClicked(_ sender: NSButton) {
        Analytics.trackView("PreferencesWindow/HotKeys")
        toggleAllTabsExcept(sender)
        switchToTabAtIndex(1)
    }

    @IBAction func mutedTabClicked(_ sender: NSButton) {
        Analytics.trackView("PreferencesWindow/Muted")
        toggleAllTabsExcept(sender)
        switchToTabAtIndex(2)
    }
}
