//
//  MainContentViewController.swift
//  Plug
//
//  Created by Alex Marchant on 9/7/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class BaseContentViewController: NSViewController {
    var loaderViewController: LoaderViewController?
    var analyticsViewName: String {
        return defaultAnalyticsViewName
    }
    var defaultAnalyticsViewName: String = "Oops, this should be overwritten"
    var dropdownMenu: NSMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addLoaderView()
    }

    func addLoaderView() {
        if loaderViewController == nil {
            loaderViewController = storyboard!.instantiateControllerWithIdentifier("LargeLoaderViewController") as? LoaderViewController
            let insets = NSEdgeInsetsMake(0, 0, 47, 0)
            ViewPlacementHelper.AddSubview(loaderViewController!.view, toSuperView: view, withInsets: insets)
        }
    }
    
    func removeLoaderView() {
        if loaderViewController != nil {
            loaderViewController!.view.removeFromSuperview()
            loaderViewController = nil
        }
    }
    
    func didBecomeCurrentViewController() {
        Notifications.subscribe(observer: self, selector: "refresh", name: Notifications.RefreshCurrentView, object: nil)
    }
    
    func didLoseCurrentViewController() {
        Notifications.unsubscribe(observer: self, name: Notifications.RefreshCurrentView, object: nil)
    }
    
    func refresh() {}
}
