//
//  GeneralPreferencesTableCellView.swift
//  Plug
//
//  Created by Alex Marchant on 8/31/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class GeneralPreferencesTableCellView: NSTableCellView {
    @IBOutlet var preferenceTitle: NSTextField!
    @IBOutlet var switchButton: IOSSwitch!
    
    override var objectValue: AnyObject! {
        didSet {
            objectValueChanged()
        }
    }
    var generalPreferenceValue: GeneralPreference {
        return objectValue as! GeneralPreference
    }

    func objectValueChanged() {
        if objectValue == nil { return }
        
        updatePreferenceTitle()
        updateSwitchButton()
    }
    
    func updatePreferenceTitle() {
        preferenceTitle.stringValue = generalPreferenceValue.title
    }
    
    func updateSwitchButton() {
        switchButton.on = generalPreferenceValue.getUserDefaultsValue()
    }
    
    @IBAction func switchButtonClicked(_ sender: IOSSwitch) {
        let oldValue = generalPreferenceValue.getUserDefaultsValue()
        let newValue = !oldValue
        generalPreferenceValue.setUserDefaultsValue(newValue)
    }
}
