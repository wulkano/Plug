//
//  MainWindowController.swift
//  Plug
//
//  Created by Alexander Marchant on 7/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        
        var closeButton = window.standardWindowButton(NSWindowButton.CloseButton)
        closeButton.hidden = true
        var minButton = window.standardWindowButton(NSWindowButton.MiniaturizeButton)
        minButton.hidden = true
        var zoomButton = window.standardWindowButton(NSWindowButton.ZoomButton)
        zoomButton.hidden = true
    }
}
