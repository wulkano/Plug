//
//  TitleBarViewController.swift
//  Plug
//
//  Created by Alex Marchant on 7/23/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class TitleBarViewController: NSViewController {
    @IBOutlet var titleTextField: NSTextField!
    
    required init(coder: NSCoder!) {
        super.init(coder: coder)
        Notifications.Subscribe.NavigationSectionChanged(self, selector: "navigationSectionChanged:")
    }
    
    deinit {
        Notifications.Unsubscribe.All(self)
    }
    
    func navigationSectionChanged(notification: NSNotification) {
        let section = Notifications.Read.NavigationSectionNotification(notification)
        updateUIForSection(section)
    }
    
    func updateUIForSection(section: NavigationSection) {
        titleTextField.stringValue = section.windowTitle()
    }
}
