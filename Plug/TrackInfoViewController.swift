//
//  TrackInfoViewController.swift
//  Plug
//
//  Created by Alex Marchant on 8/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class TrackInfoViewController: NSViewController {
    var track: Track?
    
    @IBAction func closeButtonClicked(sender: NSButton) {
        view.window?.close()
    }
}
