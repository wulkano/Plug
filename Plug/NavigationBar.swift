//
//  NavigationBar.swift
//  navigationControllers
//
//  Created by Alex Marchant on 9/2/14.
//  Copyright (c) 2014 alexmarchant. All rights reserved.
//

import Cocoa

// TODO: Should move this to some kind of controller probably

class NavigationBar: NSView {
    @IBOutlet var backButton: NSButton!
    @IBOutlet var titleTextField: NSTextField!
    @IBOutlet var titleDropdownButton: TitleBarPopUpButton!
    @IBOutlet var actionButton: ActionButton!
    
    func currentViewControllerUpdated(viewController: BaseContentViewController) {
        updateDropdownMenu(viewController)
        updateActionButton(viewController)
    }
    
    func previousViewControllerUpdated(viewController: BaseContentViewController?) {
        updateBackButton(viewController)
    }
    
    func updateDropdownMenu(viewController: BaseContentViewController) {
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
    
    func updateActionButton(viewController: BaseContentViewController) {
        viewController.actionButton = actionButton
        actionButton.onStateTitle = viewController.actionButtonOnTitle
        actionButton.offStateTitle = viewController.actionButtonOffTitle
        actionButton.state = viewController.actionButtonDefaultState
        actionButton.hidden = !viewController.displayActionButton
        actionButton.target = viewController.actionButtonTarget
        if let action = viewController.actionButtonAction {
            actionButton.action = action
        }
    }
    
    func updateBackButton(viewController: BaseContentViewController?) {
        if viewController == nil {
            backButton.hidden = true
            backButton.title = ""
        } else {
            backButton.hidden = false
            backButton.title = viewController!.title!
        }
    }
}
