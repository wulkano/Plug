//
//  PreferencesWindowController.swift
//  Plug
//
//  Created by Alex Marchant on 8/25/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController {
    var trafficButtons: TrafficButtons!
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        window!.titleVisibility = NSWindowTitleVisibility.Visible
        
        trafficButtons = TrafficButtons(style: .Light, groupIdentifier: "LoginWindow")
        trafficButtons.addButtonsToWindow(window!, origin: NSMakePoint(10, 10))
    }
}
