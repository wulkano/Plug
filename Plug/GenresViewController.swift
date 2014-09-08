//
//  GenresViewController.swift
//  Plug
//
//  Created by Alex Marchant on 8/1/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class GenresViewController: BaseContentViewController, NSTableViewDelegate, ExtendedTableViewDelegate {
    @IBOutlet var tableView: ExtendedTableView!
    var dataSource: GenresDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.setDelegate(self)
        tableView.extendedDelegate = self

        self.dataSource = GenresDataSource(viewController: self)
        tableView.setDataSource(dataSource)
        self.dataSource.loadInitialValues()
    }
    
    func itemForRow(row: Int) -> GenresListItem {
        return dataSource!.itemForRow(row)
    }
    
    func itemAfterRow(row: Int) -> GenresListItem? {
        return dataSource!.itemAfterRow(row)
    }
    
    func selectedGenre() -> Genre? {
        let row = tableView.selectedRow
        let item = itemForRow(row)
        switch itemForRow(row) {
        case .GenreItem(let genre):
            return genre
        default:
            return nil
        }
    }
    
    func tableView(tableView: NSTableView!, viewForTableColumn tableColumn: NSTableColumn!, row: Int) -> NSView! {
        switch itemForRow(row) {
        case .SectionHeaderItem:
            return  tableView.makeViewWithIdentifier("SectionHeader", owner: self) as NSView
        case .GenreItem:
            return tableView.makeViewWithIdentifier("GenreTableCellView", owner: self) as NSView
        }
    }
    
    func tableView(tableView: NSTableView!, isGroupRow row: Int) -> Bool {
        switch itemForRow(row) {
        case .SectionHeaderItem:
            return  true
        case .GenreItem:
            return false
        }
    }
    
    func tableView(tableView: NSTableView!, heightOfRow row: Int) -> CGFloat {
        switch itemForRow(row) {
        case .SectionHeaderItem:
            return  32
        case .GenreItem:
            return 48
        }
    }
    
    func tableView(tableView: NSTableView!, rowViewForRow row: Int) -> NSTableRowView! {
        switch itemForRow(row) {
        case .SectionHeaderItem:
            let rowView = tableView.makeViewWithIdentifier("GroupRow", owner: self) as NSTableRowView
            return rowView
        case .GenreItem:
            let rowView = tableView.makeViewWithIdentifier("IOSStyleTableRowView", owner: self) as IOSStyleTableRowView
            if let nextItem = itemAfterRow(row) {
                switch nextItem {
                case .SectionHeaderItem:
                    rowView.nextRowIsGroupRow = true
                case .GenreItem:
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
        case .GenreItem:
            return true
        }
    }
    
    @IBAction func searchFieldSubmit(sender: NSSearchField) {
        let keywords = sender.stringValue
        dataSource!.filterByKeywords(keywords)
    }
    
    override func keyDown(theEvent: NSEvent!) {
        switch theEvent.keyCode {
        case 36:
            enterKeyPressed(theEvent)
        case 124:
            rightArrowKeyPressed(theEvent)
        default:
            super.keyDown(theEvent)
        }
    }
    
    func enterKeyPressed(theEvent: NSEvent!) {
        if let genre = selectedGenre() {
            loadSingleGenreView(genre)
        } else {
            super.keyDown(theEvent)
        }
    }
    
    func rightArrowKeyPressed(theEvent: NSEvent!) {
        if let genre = selectedGenre() {
            loadSingleGenreView(genre)
        } else {
            super.keyDown(theEvent)
        }
    }
    
    func tableView(tableView: NSTableView, wasClicked theEvent: NSEvent, atRow row: Int) {
        switch itemForRow(row) {
        case .GenreItem(let genre):
            loadSingleGenreView(genre)
        case .SectionHeaderItem:
            return
        }
    }
    
    func loadSingleGenreView(genre: Genre) {
        var viewController = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier("BasePlaylistViewController") as BasePlaylistViewController
        viewController.title = genre.name
        Notifications.Post.PushViewController(viewController, sender: self)
        viewController.dataSource = GenrePlaylistDataSource(genre: genre, viewController: viewController)
    }
    
    func requestInitialValuesFinished() {
        removeLoaderView()
    }
}
