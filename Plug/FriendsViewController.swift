//
//  FriendsViewController.swift
//  Plug
//
//  Created by Alex Marchant on 8/1/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class FriendsViewController: NSViewController, NSTableViewDelegate {
    @IBOutlet var tableView: NSTableView!
    var dataSource: FriendsDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setDelegate(self)
        if dataSource != nil {
            tableView.setDataSource(dataSource)
            dataSource!.tableView = tableView
        }
    }
    
    func setDataSource(dataSource: FriendsDataSource) {
        self.dataSource = dataSource
        self.dataSource!.tableView = tableView
        self.dataSource!.loadInitialValues()
    }
}