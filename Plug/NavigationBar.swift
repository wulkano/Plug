//
//  NavigationBar.swift
//  navigationControllers
//
//  Created by Alex Marchant on 9/2/14.
//  Copyright (c) 2014 alexmarchant. All rights reserved.
//

import Cocoa

class NavigationBar: NSView {
    @IBOutlet var titleTextField: NSTextField!
    var title: String? {
        didSet {
            titleTextField.stringValue = title
        }
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
}
