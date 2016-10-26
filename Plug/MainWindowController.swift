//
//  MainWindowController.swift
//  Plug
//
//  Created by Alex Marchant on 10/11/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
    var trafficButtons: TrafficButtons!

    override func windowDidLoad() {
        super.windowDidLoad()
    
        trafficButtons = TrafficButtons(style: .dark, groupIdentifier: "MainWindow")
        trafficButtons.addButtonsToWindow(window!, origin: NSMakePoint(8, 10))
    }
    
    override func keyDown(with theEvent: NSEvent) {
        // 49 is the key for the space bar
        if (theEvent.keyCode == 49) {
            AudioPlayer.sharedInstance.playPauseToggle()
        }
    }
    
}
