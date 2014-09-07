//
//  FriendsViewController.swift
//  Plug
//
//  Created by Alex Marchant on 8/1/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class FriendsViewController: NSViewController, NSTableViewDelegate, ExtendedTableViewDelegate {
    @IBOutlet var tableView: ExtendedTableView!
    var dataSource: FriendsDataSource!
    var loaderViewController: LoaderViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.setDelegate(self)
        tableView.extendedDelegate = self

        dataSource = FriendsDataSource(viewController: self)
        tableView.setDataSource(dataSource)
        addLoaderView()
        dataSource.loadInitialValues()
    }
    
    @IBAction func searchFieldSubmit(sender: NSSearchField) {
        let keywords = sender.stringValue
        dataSource.filterByKeywords(keywords)
    }
    
    func tableView(tableView: NSTableView, didClickRow row: Int) {
        let friend = dataSource.itemForRow(row)
        loadSingleFriendView(friend)
    }
    
    func loadSingleFriendView(friend: Friend) {
        var viewController = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier("SingleFriendViewController") as SingleFriendViewController
        Notifications.Post.PushViewController(viewController, sender: self)
        viewController.representedObject = friend
    }
    
    func requestInitialValuesFinished() {
        removeLoaderView()
    }
    
    func addLoaderView() {
        loaderViewController = storyboard.instantiateControllerWithIdentifier("LargeLoaderViewController") as? LoaderViewController
        let insets = NSEdgeInsetsMake(0, 0, 47, 0)
        ViewPlacementHelper.AddSubview(loaderViewController!.view, toSuperView: view, withInsets: insets)
    }
    
    func removeLoaderView() {
        loaderViewController!.view.removeFromSuperview()
        loaderViewController = nil
    }
}