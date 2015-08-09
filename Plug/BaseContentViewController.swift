//
//  MainContentViewController.swift
//  Plug
//
//  Created by Alex Marchant on 9/7/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI
import SnapKit

class BaseContentViewController: NSViewController {
    let analyticsViewName: String
    var loaderViewController: LoaderViewController?
    var navigationItem: NavigationItem!
    
    init?(title: String, analyticsViewName: String) {
        self.analyticsViewName = analyticsViewName
        super.init(nibName: nil, bundle: nil)
        self.title = title
        navigationItem = NavigationItem(title: self.title!)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Notifications.unsubscribeAll(observer: self)
    }
    
    override func loadView() {
        view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addLoaderView()
    }

    func addLoaderView() {
        if loaderViewController == nil {
            loaderViewController = LoaderViewController(size: .Large)
            let insets = NSEdgeInsets(top: 0, left: 0, bottom: 47, right: 0)
            view.addSubview(loaderViewController!.view)
            loaderViewController!.view.snp_makeConstraints { make in
                make.edges.equalTo(self.view).insets(insets)
            }
        }
    }
    
    func removeLoaderView() {
        if loaderViewController != nil {
            loaderViewController!.view.removeFromSuperview()
            loaderViewController = nil
        }
    }
    
    func didBecomeCurrentViewController() {
        Notifications.subscribe(observer: self, selector: "updateStickyTrack:", name: Notifications.NewCurrentTrack, object: nil)
    }
    
    func didLoseCurrentViewController() {
        Notifications.unsubscribe(observer: self, name: Notifications.RefreshCurrentView, object: nil)
    }
    
    func refresh() {
        fatalError("refresh() not implemented")
    }
}

enum StickyTrackPosition: Int {
    case Top
    case Bottom
}
