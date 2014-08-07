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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "navigationSectionChanged:", name: Notifications.NavigationSectionChanged, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        TODO: Fix this if
        if titleTextField {
            titleTextField.stringValue = ""
        }
    }
    
    func navigationSectionChanged(notification: NSNotification) {
        if notification.object === self { return }
        let section = NavigationSection.fromNotification(notification)
        updateUIForSection(section)
    }
    
    func updateUIForSection(section: NavigationSection) {
        titleTextField.stringValue = section.windowTitle()
    }
}
