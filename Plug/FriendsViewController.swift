//
//  FriendsViewController.swift
//  Plug
//
//  Created by Alex Marchant on 8/1/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI

class FriendsViewController: DataSourceViewController {
    var dataSource: FriendsDataSource!
    override var analyticsViewName: String {
        return "MainWindow/Friends"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.setDelegate(self)
        tableView.extendedDelegate = self

        dataSource = FriendsDataSource(viewController: self)
        tableView.setDataSource(dataSource)
        dataSource.loadInitialValues()
    }
    
    @IBAction func searchFieldSubmit(sender: NSSearchField) {
        let keywords = sender.stringValue
        dataSource.filterByKeywords(keywords)
    }
    
    override func tableView(tableView: NSTableView, wasClicked theEvent: NSEvent, atRow row: Int) {
        if let item: AnyObject = dataSource.itemForRow(row) {
            loadSingleFriendView(item as! HypeMachineAPI.User)
        }
    }
    
    func loadSingleFriendView(friend: HypeMachineAPI.User) {
        var viewController = NSStoryboard(name: "Main", bundle: nil)!.instantiateControllerWithIdentifier("SingleUserViewController") as! SingleUserViewController
        Notifications.post(name: Notifications.PushViewController, object: self, userInfo: ["viewController": viewController])
        viewController.representedObject = friend
    }
    
    override func refresh() {
        addLoaderView()
        dataSource.refresh()
    }
}