//
//  BlogsViewController.swift
//  Plug
//
//  Created by Alex Marchant on 7/25/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI

class BlogsViewController: DataSourceViewController {
    var blogDataSource: BlogsDataSource? {
        return dataSource as? BlogsDataSource
    }
    
    func itemForRow(_ row: Int) -> BlogDirectoryItem? {
        if let item: AnyObject = dataSource!.objectForRow(row) {
            return BlogDirectoryItem.fromObject(item)
        } else {
            return nil
        }
    }
    
    func itemAfterRow(_ row: Int) -> BlogDirectoryItem? {
        if let item: AnyObject = dataSource!.objectAfterRow(row) {
            return BlogDirectoryItem.fromObject(item)
        } else {
            return nil
        }
    }
    
    func loadBlogViewController(_ blog: HypeMachineAPI.Blog) {
        let viewController = BlogViewController(blog: blog)!
        NavigationController.sharedInstance!.pushViewController(viewController, animated: true)
    }
    
    func blogCellView(_ tableView: NSTableView) -> BlogTableCellView {
        let id = "BlogTableCellViewID"
        var cellView = tableView.make(withIdentifier: id, owner: self) as? BlogTableCellView
        
        if cellView == nil {
            cellView = BlogTableCellView()
            cellView!.identifier = id
            
            cellView!.nameTextField = NSTextField()
            cellView!.nameTextField.isEditable = false
            cellView!.nameTextField.isSelectable = false
            cellView!.nameTextField.isBordered = false
            cellView!.nameTextField.drawsBackground = false
            cellView!.nameTextField.font = appFont(size: 14, weight: .medium)
            cellView!.addSubview(cellView!.nameTextField)
            cellView!.nameTextField.snp_makeConstraints { make in
                make.top.equalTo(cellView!).offset(10)
                make.left.equalTo(cellView!).offset(21)
                make.right.lessThanOrEqualTo(cellView!).offset(-53)
            }
            
            let recentTopOffset: CGFloat = 2
            
            let recentTitle = NSTextField()
            recentTitle.stringValue = "Recent: "
            recentTitle.isEditable = false
            recentTitle.isSelectable = false
            recentTitle.isBordered = false
            recentTitle.drawsBackground = false
            recentTitle.font = appFont(size: 13, weight: .medium)
            recentTitle.textColor = NSColor(red256: 175, green256: 179, blue256: 181)
            cellView!.addSubview(recentTitle)
            recentTitle.snp_makeConstraints { make in
                make.top.equalTo(cellView!.nameTextField.snp_bottom).offset(recentTopOffset)
                make.left.equalTo(cellView!).offset(21)
            }
            
            cellView!.recentArtistsTextField = NSTextField()
            cellView!.recentArtistsTextField.isEditable = false
            cellView!.recentArtistsTextField.isSelectable = false
            cellView!.recentArtistsTextField.isBordered = false
            cellView!.recentArtistsTextField.drawsBackground = false
            cellView!.recentArtistsTextField.lineBreakMode = .byTruncatingTail
            cellView!.recentArtistsTextField.font = appFont(size: 13, weight: .medium)
            cellView!.recentArtistsTextField.textColor = NSColor(red256: 138, green256: 146, blue256: 150)
            cellView!.addSubview(cellView!.recentArtistsTextField)
            cellView!.recentArtistsTextField.snp_makeConstraints { make in
                make.top.equalTo(cellView!.nameTextField.snp_bottom).offset(recentTopOffset)
                make.left.equalTo(recentTitle.snp_right).offset(1)
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
    
    func blogRowView(_ tableView: NSTableView, row: Int) -> IOSStyleTableRowView {
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
                case .BlogItem:
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
        blogDataSource!.searchKeywords = sender.stringValue
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
        searchHeaderController.searchField.action = #selector(BlogsViewController.searchFieldSubmit(_:))
        
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
        
        dataSource = BlogsDataSource(viewController: self)
        tableView.dataSource = dataSource
        dataSource!.loadNextPageObjects()
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
        case .BlogItem:
            return blogCellView(tableView)
        }
    }
    
    func tableView(_ tableView: NSTableView!, rowViewForRow row: Int) -> NSTableRowView! {
        switch itemForRow(row)! {
        case .sectionHeaderItem:
            return groupRowView(tableView)
        case .BlogItem:
            return blogRowView(tableView, row: row)
        }
    }
    
    func tableView(_ tableView: NSTableView!, isGroupRow row: Int) -> Bool {
        switch itemForRow(row)! {
        case .sectionHeaderItem:
            return  true
        case .BlogItem:
            return false
        }
    }
    
    func tableView(_ tableView: NSTableView!, heightOfRow row: Int) -> CGFloat {
        switch itemForRow(row)! {
        case .sectionHeaderItem:
            return  32
        case .BlogItem:
            return 64
        }
    }
    
    func tableView(_ tableView: NSTableView!, shouldSelectRow row: Int) -> Bool {
        switch itemForRow(row)! {
        case .sectionHeaderItem:
            return false
        case .BlogItem:
            return true
        }
    }
    
    // MARK: ExtendedTableViewDelegate
    
    override func tableView(_ tableView: NSTableView, wasClicked theEvent: NSEvent, atRow row: Int) {
        switch itemForRow(row)! {
        case .BlogItem(let blog):
            loadBlogViewController(blog)
        case .sectionHeaderItem:
            return
        }
    }
}
