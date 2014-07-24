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
    
    init(coder: NSCoder!) {
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
        }
    }
    
    func navigationSectionChanged(notification: NSNotification) {
        if notification.object is TitleBarViewController { return }
        let section = NavigationSection.fromNotification(notification)
        titleTextField.stringValue = section.windowTitle()
    }
}
