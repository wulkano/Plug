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
    @IBOutlet var backButton: NSButton!

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    func currentViewControllerUpdated(viewController: NSViewController) {
        titleTextField.stringValue = "\(viewController.title)"
    }
    
    func previousViewControllerUpdated(viewController: NSViewController?) {
        if viewController == nil {
            backButton.hidden = true
            backButton.title = ""
        } else {
            backButton.hidden = false
            backButton.title = "\(viewController!.title)"
        }
    }
}
