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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addLoaderView()
    }

    func addLoaderView() {
        if loaderViewController == nil {
            loaderViewController = storyboard.instantiateControllerWithIdentifier("LargeLoaderViewController") as? LoaderViewController
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
}
