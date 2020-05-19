//
//  LoginWindowController.swift
//  Plug
//
//  Created by Alex Marchant on 10/11/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class LoginWindowController: NSWindowController {
    var trafficButtons: TrafficButtons!

    override func windowDidLoad() {
        super.windowDidLoad()

        trafficButtons = TrafficButtons(style: .dark, groupIdentifier: "LoginWindow")
        trafficButtons.addButtonsToWindow(window!, origin: NSPoint(x: 20, y: 20))
        trafficButtons.zoomButton.isEnabled = false
    }
}
