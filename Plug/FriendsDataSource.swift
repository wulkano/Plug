//
//  FriendsDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 8/12/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class FriendsDataSource: NSObject, NSTableViewDataSource {
    var tableView: NSTableView?
    var tableContents: [Friend]?
    
    // TODO: Sorting
    // TODO: Grouping
    func loadInitialValues() {
        HypeMachineAPI.Friends.AllFriends(
            {friends in
                self.tableContents = friends
                self.tableView?.reloadData()
            }, failure: {error in
                AppError.logError(error)
        })
    }
    
    func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject! {
        return tableContents![row]
    }
    
    func numberOfRowsInTableView(tableView: NSTableView!) -> Int {
        if tableContents == nil { return 0 }
        
        return tableContents!.count
    }
}