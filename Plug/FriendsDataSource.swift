//
//  FriendsDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 8/12/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class FriendsDataSource: NSObject, NSTableViewDataSource {
    var viewController: FriendsViewController
    var filtering: Bool = false
    var tableContents: [Friend]?
    var filteredTableContents: [Friend]?
    
    init(viewController: FriendsViewController) {
        self.viewController = viewController
        super.init()
    }
    
    func loadInitialValues() {
        HypeMachineAPI.Friends.AllFriends(
            {friends in
                self.generateTableContents(friends)
                self.viewController.tableView.reloadData()
                self.viewController.requestInitialValuesFinished()
            }, failure: {error in
                Notifications.Post.DisplayError(error, sender: self)
                Logger.LogError(error)
                self.viewController.requestInitialValuesFinished()
        })
    }
    
    func itemForRow(row: Int) -> Friend {
        if filtering {
            return filteredTableContents![row]
        } else {
            return tableContents![row]
        }
    }
    
    func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject! {
        
        if filtering {
            return filteredTableContents![row]
        } else {
            return tableContents![row]
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView!) -> Int {
        if tableContents == nil { return 0 }
        
        if filtering {
            return filteredTableContents!.count
        } else {
            return tableContents!.count
        }
    }
    
    func generateTableContents(friends: [Friend]) {
        tableContents = friends.sorted { $0.username.lowercaseString < $1.username.lowercaseString }
    }
    
    func filterByKeywords(keywords: String) {
        if keywords == "" {
            filtering = false
        } else {
            filtering = true
            filteredTableContents = tableContents!.filter {
                ($0.username =~ keywords) || ($0.fullName =~ keywords)
            }
        }
        viewController.tableView.reloadData()
    }
}