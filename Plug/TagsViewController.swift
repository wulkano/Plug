//
//  GenresViewController.swift
//  Plug
//
//  Created by Alex Marchant on 8/1/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI

class TagsViewController: DataSourceViewController {
    var dataSource: TagsDataSource!
    override var analyticsViewName: String {
        return "MainWindow/Tags"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.setDelegate(self)
        tableView.extendedDelegate = self

        self.dataSource = TagsDataSource(viewController: self)
        tableView.setDataSource(dataSource)
        self.dataSource.loadInitialValues()
    }
    
    func itemForRow(row: Int) -> TagsListItem? {
        if let item: AnyObject = dataSource!.itemForRow(row) {
            return TagsListItem.fromObject(item)
        } else {
            return nil
        }
    }
    
    func itemAfterRow(row: Int) -> TagsListItem? {
        if let item: AnyObject = dataSource!.itemAfterRow(row) {
            return TagsListItem.fromObject(item)
        } else {
            return nil
        }
    }
    
    func selectedTag() -> HypeMachineAPI.Tag? {
        let row = tableView.selectedRow
        if let item = itemForRow(row) {
            switch item {
            case .TagItem(let tag):
                return tag
            default:
                return nil
            }
        } else {
            return nil
        }
    }
    
    func tableView(tableView: NSTableView!, viewForTableColumn tableColumn: NSTableColumn!, row: Int) -> NSView! {
        switch itemForRow(row)! {
        case .SectionHeaderItem:
            return  tableView.makeViewWithIdentifier("SectionHeader", owner: self) as! NSView
        case .TagItem:
            return tableView.makeViewWithIdentifier("TagTableCellView", owner: self) as! NSView
        }
    }
    
    func tableView(tableView: NSTableView!, isGroupRow row: Int) -> Bool {
        switch itemForRow(row)! {
        case .SectionHeaderItem:
            return  true
        case .TagItem:
            return false
        }
    }
    
    func tableView(tableView: NSTableView!, heightOfRow row: Int) -> CGFloat {
        switch itemForRow(row)! {
        case .SectionHeaderItem:
            return  32
        case .TagItem:
            return 48
        }
    }
    
    func tableView(tableView: NSTableView!, rowViewForRow row: Int) -> NSTableRowView! {
        switch itemForRow(row)! {
        case .SectionHeaderItem:
            let rowView = tableView.makeViewWithIdentifier("GroupRow", owner: self) as! NSTableRowView
            return rowView
        case .TagItem:
            let rowView = tableView.makeViewWithIdentifier("IOSStyleTableRowView", owner: self) as! IOSStyleTableRowView
            if let nextItem = itemAfterRow(row) {
                switch nextItem {
                case .SectionHeaderItem:
                    rowView.nextRowIsGroupRow = true
                case .TagItem:
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
        case .TagItem:
            return true
        }
    }
    
    @IBAction func searchFieldSubmit(sender: NSSearchField) {
        let keywords = sender.stringValue
        dataSource!.filterByKeywords(keywords)
    }
    
    override func keyDown(theEvent: NSEvent) {
        switch theEvent.keyCode {
        case 36:
            enterKeyPressed(theEvent)
        case 124:
            rightArrowKeyPressed(theEvent)
        default:
            super.keyDown(theEvent)
        }
    }
    
    func enterKeyPressed(theEvent: NSEvent) {
        if let tag = selectedTag() {
            loadSingleTagView(tag)
        } else {
            super.keyDown(theEvent)
        }
    }
    
    func rightArrowKeyPressed(theEvent: NSEvent) {
        if let tag = selectedTag() {
            loadSingleTagView(tag)
        } else {
            super.keyDown(theEvent)
        }
    }
    
    func tableView(tableView: NSTableView, wasClicked theEvent: NSEvent, atRow row: Int) {
        switch itemForRow(row)! {
        case .TagItem(let tag):
            loadSingleTagView(tag)
        case .SectionHeaderItem:
            return
        }
    }
    
    func loadSingleTagView(tag: HypeMachineAPI.Tag) {
        var viewController = NSStoryboard(name: "Main", bundle: nil)!.instantiateControllerWithIdentifier("TracksViewController") as! TracksViewController
        viewController.title = tag.name
        Notifications.post(name: Notifications.PushViewController, object: self, userInfo: ["viewController": viewController])
        viewController.dataSource = TagTracksDataSource(tagName: tag.name)
        viewController.dataSource!.viewController = viewController
    }
    
    override func refresh() {
        addLoaderView()
        dataSource.refresh()
    }
}