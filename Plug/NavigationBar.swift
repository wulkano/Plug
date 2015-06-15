//
//  NavigationBar.swift
//  navigationControllers
//
//  Created by Alex Marchant on 9/2/14.
//  Copyright (c) 2014 alexmarchant. All rights reserved.
//

import Cocoa

class NavigationBar: NSView {
    @IBOutlet var backButton: NSButton!
    @IBOutlet var titleTextField: NSTextField!
    @IBOutlet var titleDropdownButton: TitleBarPopUpButton!
    
    func currentViewControllerUpdated(viewController: BaseContentViewController) {
        if viewController.dropdownMenu != nil {
            titleTextField.hidden = true
            titleDropdownButton.hidden = false
            
            titleDropdownButton.menu = viewController.dropdownMenu
        } else {
            titleTextField.hidden = false
            titleDropdownButton.hidden = true
            
            titleTextField.stringValue = viewController.title!
        }
    }
    
    func previousViewControllerUpdated(viewController: BaseContentViewController?) {
        if viewController == nil {
            backButton.hidden = true
            backButton.title = ""
        } else {
            backButton.hidden = false
            backButton.title = viewController!.title!
        }
    }
}
