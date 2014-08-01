//
//  FriendsViewController.swift
//  Plug
//
//  Created by Alex Marchant on 8/1/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class FriendsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet var tableView: NSTableView!
    var tableContents = [Friend]()

    override func viewDidLoad() {
        super.viewDidLoad()

        if tableView {
            tableView.setDelegate(self)
            tableView.setDataSource(self)
        }
    }
    
    func tableView(tableView: NSTableView!, rowViewForRow row: Int) -> NSTableRowView! {
        return tableView.makeViewWithIdentifier("IOSStyleTableRowView", owner: self) as IOSStyleTableRowView
    }
    
    func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject! {
        return tableContents[row]
    }
    
    func numberOfRowsInTableView(tableView: NSTableView!) -> Int {
        return tableContents.count
    }
}
