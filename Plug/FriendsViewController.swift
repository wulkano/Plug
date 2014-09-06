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
        setupDataSource()
    }
    
    func setupDataSource() {
        self.dataSource = FriendsDataSource()
        tableView.setDataSource(dataSource)
        self.dataSource!.tableView = tableView
        self.dataSource!.loadInitialValues()
    }
    
    @IBAction func searchFieldSubmit(sender: NSSearchField) {
        let keywords = sender.stringValue
        dataSource!.filterByKeywords(keywords)
    }
    
    func tableView(tableView: NSTableView, didClickRow row: Int) {
        let friend = dataSource!.itemForRow(row)
    }
}