//
//  DataSourceViewController.swift
//  Plug
//
//  Created by Alex Marchant on 10/22/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class DataSourceViewController: BaseContentViewController, NSTableViewDelegate, ExtendedTableViewDelegate {
    @IBOutlet var tableView: ExtendedTableView!
    
    func requestInitialValuesFinished() {
        removeLoaderView()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        tableView.updateVisibleRows()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        tableView.visibleRows = []
    }
    
    override func didBecomeCurrentViewController() {
        super.didBecomeCurrentViewController()
        
        Notifications.subscribe(observer: self, selector: "currentTrackDidShow:", name: Notifications.CurrentTrackDidShow, object: nil)
        Notifications.subscribe(observer: self, selector: "currentTrackDidHide:", name: Notifications.CurrentTrackDidHide, object: nil)
        
        if AudioPlayer.sharedInstance.currentTrack != nil {
            addFixedCurrentTrackViewForPosition(.Bottom)
        }
    }
    
    override func didLoseCurrentViewController() {
        super.didLoseCurrentViewController()
        
        Notifications.unsubscribe(observer: self, name: Notifications.CurrentTrackDidShow, object: nil)
        Notifications.unsubscribe(observer: self, name: Notifications.CurrentTrackDidHide, object: nil)
    }
    
    // MARK: Fixed Track Popup
    
    var currentTrackViewController: TracksViewController?
    let currentTrackViewControllerTopInsets = NSEdgeInsetsMake(0, 0, 0, 0)
    let currentTrackViewControllerBottomInsets = NSEdgeInsetsMake(0, 0, 47, 0)

    
    func currentTrackDidShow(notification: NSNotification) {
        removeCurrentTrackView()
    }
    
    func currentTrackDidHide(notification: NSNotification) {
        let direction = RowShowHideDirection(rawValue: notification.userInfo!["direction"]! as! Int)!
        switch direction {
        case .Above:
            addFixedCurrentTrackViewForPosition(.Top)
        case .Below:
            addFixedCurrentTrackViewForPosition(.Bottom)
        }
    }
    
    func addFixedCurrentTrackViewForPosition(position: FixedTrackViewPosition) {
        if currentTrackViewController != nil { removeCurrentTrackView() }
        
        currentTrackViewController = storyboard!.instantiateControllerWithIdentifier("TracksViewController") as? TracksViewController
        
        switch position {
        case .Top:
            ViewPlacementHelper.addTopAnchoredSubview(currentTrackViewController!.view, toSuperView: view, withFixedHeight: 64, andInsets: currentTrackViewControllerTopInsets)
            println("Added to top")
        case .Bottom:
            ViewPlacementHelper.addBottomAnchoredSubview(currentTrackViewController!.view, toSuperView: view, withFixedHeight: 64, andInsets: currentTrackViewControllerBottomInsets)
        }
        
        let dataSource = SingleTrackDataSource(track: AudioPlayer.sharedInstance.currentTrack)
        dataSource.viewController = currentTrackViewController
        currentTrackViewController!.dataSource = dataSource
//        currentTrackViewController!.tableView.scrollView!.horizontalScrollElasticity = .None
//        currentTrackViewController!.tableView.scrollView!.verticalScrollElasticity = .None
        
//        Notifications.post(name: Notifications.FixedCurrentTrackDidShow, object: self, userInfo: ["position": position.rawValue])
    }
    
    func removeCurrentTrackView() {
        if currentTrackViewController == nil { return }
        currentTrackViewController!.view.removeFromSuperview()
        currentTrackViewController = nil
        
        Notifications.post(name: Notifications.FixedCurrentTrackDidHide, object: self, userInfo: nil)
    }
    
    // MARK: ExtendedTableViewDelegate default implementations
    
    func tableView(tableView: ExtendedTableView, wasClicked theEvent: NSEvent, atRow row: Int) {}
    func tableView(tableView: ExtendedTableView, wasRightClicked theEvent: NSEvent, atRow row: Int) {}
    func tableView(tableView: ExtendedTableView, mouseEnteredRow row: Int) {}
    func tableView(tableView: ExtendedTableView, mouseExitedRow row: Int) {}
    func tableView(tableView: ExtendedTableView, rowDidShow row: Int, direction: RowShowHideDirection) {}
    func tableView(tableView: ExtendedTableView, rowDidHide row: Int, direction: RowShowHideDirection) {}
    func didEndScrollingTableView(tableView: ExtendedTableView) {}
    func didScrollTableView(tableView: ExtendedTableView) {}
}
