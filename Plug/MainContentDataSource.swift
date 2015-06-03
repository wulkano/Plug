//
//  BaseMainContentDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 10/22/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class MainContentDataSource: NSObject, NSTableViewDataSource {
    var viewController: DataSourceViewController
    var filtering: Bool = false
    var standardTableContents: [AnyObject] = []
    var filteredTableContents: [AnyObject] = []
    var tableContents: [AnyObject] {
        if filtering {
            return filteredTableContents
        } else {
            return standardTableContents
        }
    }
    
    init(viewController: DataSourceViewController) {
        self.viewController = viewController
        super.init()
    }
    
    func loadInitialValues() {}
    
    func refresh() {
        loadInitialValues()
    }
    
    func itemForRow(row: Int) -> AnyObject? {
        return tableContents.optionalAtIndex(row)
    }
    
    func itemAfterRow(row: Int) -> AnyObject? {
        return itemForRow(row + 1)
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return itemForRow(row)
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return tableContents.count
    }
}
