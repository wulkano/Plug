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
        Notifications.Unsubscribe.All(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Notifications.Subscribe.PushViewController(self, selector: "pushViewControllerNotification:")
    }
    
    func pushViewControllerNotification(notification: NSNotification) {
        let viewController = Notifications.Read.PushViewControllerNotification(notification)
        pushViewController(viewController, animated: true)
    }
    
}
