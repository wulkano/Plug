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

    @IBAction func generalTabClicked(sender: NSButton) {
        toggleAllTabsExcept(sender)
        switchToTabAtIndex(0)
    }
    
    @IBAction func hotkeysTabClicked(sender: NSButton) {
        toggleAllTabsExcept(sender)
        switchToTabAtIndex(1)
    }

    @IBAction func mutedTabClicked(sender: NSButton) {
        toggleAllTabsExcept(sender)
        switchToTabAtIndex(2)
    }
    
    func toggleAllTabsExcept(sender: NSButton) {
        let allTabs = [
            generalTab,
            hotkeysTab,
            mutedTab,
        ]
        for tab in allTabs {
            if tab === sender { continue }
            tab.state = NSOffState
        }
    }
    
    func switchToTabAtIndex(index: Int) {
        ensureTabViewController()
        tabViewController.selectedTabViewItemIndex = index
    }
    
    func ensureTabViewController() {
        if tabViewController != nil { return }
        
        for controller in childViewControllers {
            if controller is NSTabViewController {
                tabViewController = controller as? NSTabViewController
            }
        }
    }
}
