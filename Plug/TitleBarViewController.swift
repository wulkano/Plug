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
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        Notifications.subscribe(observer: self, selector: "navigationSectionChanged:", name: Notifications.NavigationSectionChanged, object: nil)
    }
    
    deinit {
        Notifications.unsubscribeAll(observer: self)
    }
    
    func navigationSectionChanged(notification: NSNotification) {
        let raw = (notification.userInfo!["navigationSection"] as! NSNumber).integerValue
        let section = NavigationSection(rawValue: raw)!
        updateUIForSection(section)
    }
    
    func updateUIForSection(section: NavigationSection) {
        println("\(section.windowTitle())")
        titleTextField.stringValue = section.windowTitle()
    }
}
