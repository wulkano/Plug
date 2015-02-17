//
//  PlugNavigationController.swift
//  Plug
//
//  Created by Alex Marchant on 9/2/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PlugNavigationController: NavigationController {
    
    deinit {
        Notifications.unsubscribeAll(observer: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Notifications.subscribe(observer: self, selector: "pushViewControllerNotification:", name: Notifications.PushViewController, object: nil)
    }
    
    func pushViewControllerNotification(notification: NSNotification) {
        let viewController = notification.userInfo!["viewController"] as! BaseContentViewController
        pushViewController(viewController)
    }
    
}
