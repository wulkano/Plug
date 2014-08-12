//
//  BlogDirectoryViewController.swift
//  Plug
//
//  Created by Alex Marchant on 7/25/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class BlogDirectoryViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet var tableView: NSTableView!
    var tableContents = [BlogDirectoryItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setDelegate(self)
        tableView.setDataSource(self)
    }
    
    func itemForRow(row: Int) -> BlogDirectoryItem {
        return tableContents[row]
    }
    
    func itemAfterRow(row: Int) -> BlogDirectoryItem? {
        if tableContents.count - 1 > row {
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
    
    func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject! {
        switch itemForRow(row) {
        case .SectionHeaderItem(let sectionHeader):
            return sectionHeader
        case .BlogItem(let blog):
            return blog
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView!) -> Int {
        return tableContents.count
    }
    
    func tableView(tableView: NSTableView!, shouldSelectRow row: Int) -> Bool {
        switch itemForRow(row) {
        case .SectionHeaderItem(let sectionHeader):
            return false
        case .BlogItem(let blog):
            return true
        }
    }
}

enum BlogDirectoryItem {
    case SectionHeaderItem(SectionHeader)
    case BlogItem(Blog)
}
