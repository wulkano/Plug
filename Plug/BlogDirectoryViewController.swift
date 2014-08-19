//
//  BlogDirectoryViewController.swift
//  Plug
//
//  Created by Alex Marchant on 7/25/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class BlogDirectoryViewController: NSViewController, NSTableViewDelegate {
    @IBOutlet var tableView: NSTableView!
    var dataSource: BlogDirectoryDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setDelegate(self)
        if dataSource != nil {
            tableView.setDataSource(dataSource)
            dataSource!.tableView = tableView
        }
    }
    
    func setDataSource(dataSource: BlogDirectoryDataSource) {
        self.dataSource = dataSource
        self.dataSource!.tableView = tableView
        self.dataSource!.loadInitialValues()
    }
    
    func itemForRow(row: Int) -> BlogDirectoryItem {
        return dataSource!.tableContents![row]
    }
    
    func itemAfterRow(row: Int) -> BlogDirectoryItem? {
        if dataSource!.tableContents!.count - 1 > row {
            return itemForRow(row + 1)
        } else {
            return nil
        }
    }
    
    func tableView(tableView: NSTableView!, viewForTableColumn tableColumn: NSTableColumn!, row: Int) -> NSView! {
        switch itemForRow(row) {
        case .SectionHeaderItem:
            return  tableView.makeViewWithIdentifier("SectionHeader", owner: self) as NSView
        case .BlogItem:
            return tableView.makeViewWithIdentifier("BlogDirectoryBlog", owner: self) as NSView
        }
    }
    
    func tableView(tableView: NSTableView!, isGroupRow row: Int) -> Bool {
        switch itemForRow(row) {
        case .SectionHeaderItem:
            return  true
        case .BlogItem:
            return false
        }
    }
    
    func tableView(tableView: NSTableView!, heightOfRow row: Int) -> CGFloat {
        switch itemForRow(row) {
        case .SectionHeaderItem:
            return  32
        case .BlogItem:
            return 64
        }
    }
    
    func tableView(tableView: NSTableView!, rowViewForRow row: Int) -> NSTableRowView! {
        switch itemForRow(row) {
        case .SectionHeaderItem:
            let rowView = tableView.makeViewWithIdentifier("GroupRow", owner: self) as NSTableRowView
            return rowView
        case .BlogItem:
            let rowView = tableView.makeViewWithIdentifier("IOSStyleTableRowView", owner: self) as IOSStyleTableRowView
            if let nextItem = itemAfterRow(row) {
                switch nextItem {
                case .SectionHeaderItem:
                    rowView.nextRowIsGroupRow = true
                case .BlogItem:
                    rowView.nextRowIsGroupRow = false
                }
            } else {
                rowView.nextRowIsGroupRow = false
            }
            return rowView
        }
    }
    
    func tableView(tableView: NSTableView!, shouldSelectRow row: Int) -> Bool {
        switch itemForRow(row) {
        case .SectionHeaderItem:
            return false
        case .BlogItem:
            return true
        }
    }
}