//
//  FriendsViewController.swift
//  Plug
//
//  Created by Alex Marchant on 8/1/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class FriendsViewController: BaseContentViewController, NSTableViewDelegate, ExtendedTableViewDelegate {
    @IBOutlet var tableView: ExtendedTableView!
    var dataSource: FriendsDataSource!

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
    
    func tableView(tableView: NSTableView, wasClicked theEvent: NSEvent, atRow row: Int) {
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
}