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

		window!.titleVisibility = NSWindow.TitleVisibility.visible

        trafficButtons = TrafficButtons(style: .light, groupIdentifier: "PreferencesWindow")
        trafficButtons.addButtonsToWindow(window!, origin: NSPoint(x: 10, y: 8))
        trafficButtons.zoomButton.isEnabled = false
    }
}
