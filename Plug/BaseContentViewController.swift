//
//  MainContentViewController.swift
//  Plug
//
//  Created by Alex Marchant on 9/7/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI

class BaseContentViewController: NSViewController {
    var loaderViewController: LoaderViewController?
    var analyticsViewName: String {
        return defaultAnalyticsViewName
    }
    var defaultAnalyticsViewName: String = "Oops, this should be overwritten"
    var dropdownMenu: NSMenu?

    var actionButton: ActionButton?
    var displayActionButton: Bool = false
    var actionButtonDefaultState: Int = NSOffState
    var actionButtonOffTitle: String = "Follow"
    var actionButtonOnTitle: String = "Unfollow"
    var actionButtonTarget: AnyObject?
    var actionButtonAction: Selector?
    
    deinit {
        Notifications.unsubscribeAll(observer: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addLoaderView()
        setupStickyTrackController()
    }

    func addLoaderView() {
        if loaderViewController == nil {
            loaderViewController = storyboard!.instantiateControllerWithIdentifier("LargeLoaderViewController") as? LoaderViewController
            let insets = NSEdgeInsets(top: 47, left: 0, bottom: 0, right: 0)
            ViewPlacementHelper.addSubview(loaderViewController!.view, toSuperView: view, withInsets: insets)
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
        Notifications.subscribe(observer: self, selector: "updateStickyTrack:", name: Notifications.NewCurrentTrack, object: nil)
    }
    
    func didLoseCurrentViewController() {
        Notifications.unsubscribe(observer: self, name: Notifications.RefreshCurrentView, object: nil)
    }
    
    // MARK: Sticky Track
    
    var stickyTrackController: TracksViewController!
    var stickyTrackTopInsets: NSEdgeInsets {
        return NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    var stickyTrackBottomInsets: NSEdgeInsets {
        return NSEdgeInsets(top: 0, left: 0, bottom: 47, right: 0)
    }
    var stickyTrackHeight: CGFloat {
        return 64
    }
    
    func setupStickyTrackController() {
        stickyTrackController = storyboard!.instantiateControllerWithIdentifier("TracksViewController") as? TracksViewController
    }
    
    func addStickyTrackAtPosition(position: StickyTrackPosition) {
        switch position {
        case .Top:
            ViewPlacementHelper.addTopAnchoredSubview(stickyTrackController.view, toSuperView: view, withFixedHeight: stickyTrackHeight, andInsets: stickyTrackTopInsets)
        case .Bottom:
            ViewPlacementHelper.addBottomAnchoredSubview(stickyTrackController.view, toSuperView: view, withFixedHeight: stickyTrackHeight, andInsets: stickyTrackBottomInsets)
        }
    }
    
    func removeStickyTrack() {
        stickyTrackController.view.removeFromSuperview()
    }
    
    // MARK: Notifications
    
    func refresh() {}
    
    func updateStickyTrack(notification: NSNotification) {
        let track = notification.userInfo!["track"] as! HypeMachineAPI.Track
        stickyTrackController.dataSource = SingleTrackDataSource(viewController: stickyTrackController, track: track)
    }
}

enum StickyTrackPosition: Int {
    case Top
    case Bottom
}
