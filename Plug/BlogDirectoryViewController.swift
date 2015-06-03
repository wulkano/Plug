//
//  BlogDirectoryViewController.swift
//  Plug
//
//  Created by Alex Marchant on 7/25/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI

class BlogDirectoryViewController: DataSourceViewController {
    var dataSource: BlogDirectoryDataSource!
    override var analyticsViewName: String {
        return "MainWindow/BlogDirectory"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.setDelegate(self)
        tableView.extendedDelegate = self
        
        dataSource = BlogDirectoryDataSource(viewController: self)
        tableView.setDataSource(dataSource)
        dataSource.loadInitialValues()
    }
    
    func itemForRow(row: Int) -> BlogDirectoryItem? {
        if let item: AnyObject = dataSource.itemForRow(row) {
            return BlogDirectoryItem.fromObject(item)
        } else {
            return nil
        }
    }
    
    func itemAfterRow(row: Int) -> BlogDirectoryItem? {
        if let item: AnyObject = dataSource.itemAfterRow(row) {
            return BlogDirectoryItem.fromObject(item)
        } else {
            return nil
        }
    }
    
    func tableView(tableView: NSTableView!, viewForTableColumn tableColumn: NSTableColumn!, row: Int) -> NSView! {
        
        switch itemForRow(row)! {
        case .SectionHeaderItem:
            return  tableView.makeViewWithIdentifier("SectionHeader", owner: self) as! NSView
        case .BlogItem:
            return tableView.makeViewWithIdentifier("BlogDirectoryBlog", owner: self) as! NSView
        }
    }
    
    func tableView(tableView: NSTableView!, isGroupRow row: Int) -> Bool {
        switch itemForRow(row)! {
        case .SectionHeaderItem:
            return  true
        case .BlogItem:
            return false
        }
    }
    
    func tableView(tableView: NSTableView!, heightOfRow row: Int) -> CGFloat {
        switch itemForRow(row)! {
        case .SectionHeaderItem:
            return  32
        case .BlogItem:
            return 64
        }
    }
    
    func tableView(tableView: NSTableView!, rowViewForRow row: Int) -> NSTableRowView! {
        switch itemForRow(row)! {
        case .SectionHeaderItem:
            let rowView = tableView.makeViewWithIdentifier("GroupRow", owner: self) as! NSTableRowView
            return rowView
        case .BlogItem:
            let rowView = tableView.makeViewWithIdentifier("IOSStyleTableRowView", owner: self) as! IOSStyleTableRowView
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
        switch itemForRow(row)! {
        case .SectionHeaderItem:
            return false
        case .BlogItem:
            return true
        }
    }
    
    @IBAction func searchFieldSubmit(sender: NSSearchField) {
        let keywords = sender.stringValue
        dataSource.filterByKeywords(keywords)
    }
    
    func tableView(tableView: NSTableView, wasClicked theEvent: NSEvent, atRow row: Int) {
        switch itemForRow(row)! {
        case .BlogItem(let blog):
            loadSingleBlogView(blog)
        case .SectionHeaderItem:
            return
        }
    }
    
    func loadSingleBlogView(blog: HypeMachineAPI.Blog) {
        var viewController = NSStoryboard(name: "Main", bundle: nil)!.instantiateControllerWithIdentifier("SingleBlogViewController") as! SingleBlogViewController
        Notifications.post(name: Notifications.PushViewController, object: self, userInfo: ["viewController": viewController])
        viewController.representedObject = blog
    }
    
    override func refresh() {
        addLoaderView()
        dataSource.refresh()
    }
}
