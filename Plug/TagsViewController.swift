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
    var tagsDataSource: TagsDataSource? {
        return dataSource as? TagsDataSource
    }
    
    func itemForRow(_ row: Int) -> TagsListItem? {
        if let item: AnyObject = dataSource!.objectForRow(row) {
            return TagsListItem.fromObject(item)
        } else {
            return nil
        }
    }
    
    func itemAfterRow(_ row: Int) -> TagsListItem? {
        if let item: AnyObject = dataSource!.objectForRow(row) {
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
    
    func enterKeyPressed(_ theEvent: NSEvent) {
        if let tag = selectedTag() {
            loadSingleTagView(tag)
        } else {
            super.keyDown(with: theEvent)
        }
    }
    
    func rightArrowKeyPressed(_ theEvent: NSEvent) {
        if let tag = selectedTag() {
            loadSingleTagView(tag)
        } else {
            super.keyDown(with: theEvent)
        }
    }
    
    func loadSingleTagView(_ tag: HypeMachineAPI.Tag) {
        let viewController = TracksViewController(type: .LoveCount, title: tag.name, analyticsViewName: "Tag/Tracks")!
        NavigationController.sharedInstance!.pushViewController(viewController, animated: true)
        viewController.dataSource = TagTracksDataSource(viewController: viewController, tagName: tag.name)
    }
    
    func tagCellView(_ tableView: NSTableView) -> TagTableCellView {
        let id = "TagTableCellViewID"
        var cellView = tableView.make(withIdentifier: id, owner: self) as? TagTableCellView
        
        if cellView == nil {
            cellView = TagTableCellView()
            cellView!.identifier = id
            
            cellView!.nameTextField = NSTextField()
            cellView!.nameTextField.isEditable = false
            cellView!.nameTextField.isSelectable = false
            cellView!.nameTextField.isBordered = false
            cellView!.nameTextField.drawsBackground = false
            cellView!.nameTextField.font = appFont(size: 16, weight: .medium)
            cellView!.addSubview(cellView!.nameTextField)
            cellView!.nameTextField.snp_makeConstraints { make in
                make.centerY.equalTo(cellView!).offset(1)
                make.left.equalTo(cellView!).offset(21)
                make.right.lessThanOrEqualTo(cellView!).offset(-53)
            }
            
            let arrow = NSImageView()
            arrow.image = NSImage(named: "List-Arrow")!
            cellView!.addSubview(arrow)
            arrow.snp_makeConstraints { make in
                make.centerY.equalTo(cellView!)
                make.right.equalTo(cellView!).offset(-15)
            }
        }
        
        return cellView!
    }
    
    func tagRowView(_ tableView: NSTableView, row: Int) -> IOSStyleTableRowView {
        let id = "IOSStyleTableRowViewID"
        var rowView = tableView.make(withIdentifier: id, owner: self) as? IOSStyleTableRowView
        
        if rowView == nil {
            rowView = IOSStyleTableRowView()
            rowView!.identifier = id
            rowView!.separatorSpacing = 21
            
            if let nextItem = itemAfterRow(row) {
                switch nextItem {
                case .sectionHeaderItem:
                    rowView!.nextRowIsGroupRow = true
                case .TagItem:
                    rowView!.nextRowIsGroupRow = false
                }
            } else {
                rowView!.nextRowIsGroupRow = false
            }
        }
        
        return rowView!
    }
    
    // MARK: Actions
    
    func searchFieldSubmit(_ sender: NSSearchField) {
        tagsDataSource!.searchKeywords = sender.stringValue
    }
    
    // MARK: NSResponder
    
    override func keyDown(with theEvent: NSEvent) {
        switch theEvent.keyCode {
        case 36:
            enterKeyPressed(theEvent)
        case 124:
            rightArrowKeyPressed(theEvent)
        default:
            super.keyDown(with: theEvent)
        }
    }
    
    // MARK: NSViewController
    
    override func loadView() {
        super.loadView()
        
        let searchHeaderController = SearchHeaderViewController(nibName: nil, bundle: nil)!
        view.addSubview(searchHeaderController.view)
        searchHeaderController.view.snp_makeConstraints { make in
            make.height.equalTo(52)
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        searchHeaderController.searchField.target = self
        searchHeaderController.searchField.action = #selector(TagsViewController.searchFieldSubmit(_:))
        
        loadScrollViewAndTableView()
        scrollView.snp_makeConstraints { make in
            make.top.equalTo(searchHeaderController.view.snp_bottom)
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.right.equalTo(self.view)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.extendedDelegate = self
        
        self.dataSource = TagsDataSource(viewController: self)
        tableView.dataSource = dataSource
        self.dataSource?.loadNextPageObjects()
    }
    
    override func refresh() {
        addLoaderView()
        dataSource!.refresh()
    }
    
    // MARK: NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView!, viewForTableColumn tableColumn: NSTableColumn!, row: Int) -> NSView! {
        switch itemForRow(row)! {
        case .sectionHeaderItem:
            return sectionHeaderCellView(tableView)
        case .TagItem:
            return tagCellView(tableView)
        }
    }
    
    func tableView(_ tableView: NSTableView!, rowViewForRow row: Int) -> NSTableRowView! {
        switch itemForRow(row)! {
        case .sectionHeaderItem:
            return groupRowView(tableView)
        case .TagItem:
            return tagRowView(tableView, row: row)
        }
    }
    
    func tableView(_ tableView: NSTableView!, isGroupRow row: Int) -> Bool {
        switch itemForRow(row)! {
        case .sectionHeaderItem:
            return  true
        case .TagItem:
            return false
        }
    }
    
    func tableView(_ tableView: NSTableView!, heightOfRow row: Int) -> CGFloat {
        switch itemForRow(row)! {
        case .sectionHeaderItem:
            return 32
        case .TagItem:
            return 48
        }
    }
    
    func tableView(_ tableView: NSTableView!, shouldSelectRow row: Int) -> Bool {
        switch itemForRow(row)! {
        case .sectionHeaderItem:
            return false
        case .TagItem:
            return true
        }
    }
    
    // MARK: ExtendedTableViewDelegate
    
    override func tableView(_ tableView: NSTableView, wasClicked theEvent: NSEvent, atRow row: Int) {
        switch itemForRow(row)! {
        case .TagItem(let tag):
            loadSingleTagView(tag)
        case .sectionHeaderItem:
            return
        }
    }
}
