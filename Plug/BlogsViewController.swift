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
    var dataSource: BlogsDataSource!
    override var analyticsViewName: String {
        return "MainWindow/BlogDirectory"
    }
    
    override func loadView() {
        view = NSView()
        
        let searchHeaderController = SearchHeaderViewController(nibName: nil, bundle: nil)!
        view.addSubview(searchHeaderController.view)
        searchHeaderController.view.snp_makeConstraints { make in
            make.height.equalTo(52)
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        searchHeaderController.searchField.target = self
        searchHeaderController.searchField.action = "searchFieldSubmit:"
        
        let scrollView = NSScrollView()
        view.addSubview(scrollView)
        scrollView.snp_makeConstraints { make in
            make.top.equalTo(searchHeaderController.view.snp_bottom)
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        tableView = InsetTableView()
        tableView.headerView = nil
        tableView.intercellSpacing = NSSize(width: 0, height: 0)
        let column = NSTableColumn(identifier: "Col0")
        column.width = 400
        column.minWidth = 40
        column.maxWidth = 1000
        tableView.addTableColumn(column)
        
        scrollView.documentView = tableView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.horizontalScrollElasticity = .None
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.setDelegate(self)
        tableView.extendedDelegate = self
        
        dataSource = BlogsDataSource(viewController: self)
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
    
    func loadBlogViewController(blog: HypeMachineAPI.Blog) {
        var viewController = BlogViewController(blog: blog)
        Notifications.post(name: Notifications.PushViewController, object: self, userInfo: ["viewController": viewController])
    }
    
    override func refresh() {
        addLoaderView()
        dataSource.refresh()
    }
    
    func blogCellView(tableView: NSTableView) -> BlogTableCellView {
        let id = "BlogTableCellViewID"
        var cellView = tableView.makeViewWithIdentifier(id, owner: self) as? BlogTableCellView
        
        if cellView == nil {
            cellView = BlogTableCellView()
            cellView!.identifier = id
            
            cellView!.nameTextField = NSTextField()
            cellView!.nameTextField.editable = false
            cellView!.nameTextField.selectable = false
            cellView!.nameTextField.bordered = false
            cellView!.nameTextField.drawsBackground = false
            cellView!.nameTextField.font = NSFont(name: "HelveticaNeue-Medium", size: 14)
            cellView!.addSubview(cellView!.nameTextField)
            cellView!.nameTextField.snp_makeConstraints { make in
                make.top.equalTo(cellView!).offset(9)
                make.left.equalTo(cellView!).offset(21)
                make.right.lessThanOrEqualTo(cellView!).offset(-53)
            }
            
            let recentTitle = NSTextField()
            recentTitle.stringValue = "Recent: "
            recentTitle.editable = false
            recentTitle.selectable = false
            recentTitle.bordered = false
            recentTitle.drawsBackground = false
            recentTitle.font = NSFont(name: "HelveticaNeue-Medium", size: 13)
            recentTitle.textColor = NSColor(red256: 175, green256: 179, blue256: 181)
            cellView!.addSubview(recentTitle)
            recentTitle.snp_makeConstraints { make in
                make.top.equalTo(cellView!.nameTextField.snp_bottom).offset(1)
                make.left.equalTo(cellView!).offset(21)
            }
            
            cellView!.recentArtistsTextField = NSTextField()
            cellView!.recentArtistsTextField.editable = false
            cellView!.recentArtistsTextField.selectable = false
            cellView!.recentArtistsTextField.bordered = false
            cellView!.recentArtistsTextField.drawsBackground = false
            cellView!.recentArtistsTextField.lineBreakMode = .ByTruncatingTail
            cellView!.recentArtistsTextField.font = NSFont(name: "HelveticaNeue-Medium", size: 13)
            cellView!.recentArtistsTextField.textColor = NSColor(red256: 138, green256: 146, blue256: 150)
            cellView!.addSubview(cellView!.recentArtistsTextField)
            cellView!.recentArtistsTextField.snp_makeConstraints { make in
                make.top.equalTo(cellView!.nameTextField.snp_bottom).offset(1)
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
    
    func blogRowView(tableView: NSTableView, row: Int) -> IOSStyleTableRowView {
        let id = "IOSStyleTableRowViewID"
        var rowView = tableView.makeViewWithIdentifier(id, owner: self) as? IOSStyleTableRowView
        
        if rowView == nil {
            rowView = IOSStyleTableRowView()
            rowView!.identifier = id
            rowView!.separatorSpacing = 21
            
            if let nextItem = itemAfterRow(row) {
                switch nextItem {
                case .SectionHeaderItem:
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
    
    // MARK: NSTableViewDelegate
    
    func tableView(tableView: NSTableView!, viewForTableColumn tableColumn: NSTableColumn!, row: Int) -> NSView! {
        switch itemForRow(row)! {
        case .SectionHeaderItem:
            return sectionHeaderCellView(tableView)
        case .BlogItem:
            return blogCellView(tableView)
        }
    }
    
    func tableView(tableView: NSTableView!, rowViewForRow row: Int) -> NSTableRowView! {
        switch itemForRow(row)! {
        case .SectionHeaderItem:
            return groupRowView(tableView)
        case .BlogItem:
            return blogRowView(tableView, row: row)
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
    
    func tableView(tableView: NSTableView!, shouldSelectRow row: Int) -> Bool {
        switch itemForRow(row)! {
        case .SectionHeaderItem:
            return false
        case .BlogItem:
            return true
        }
    }
    
    // MARK: ExtendedTableViewDelegate
    
    override func tableView(tableView: NSTableView, wasClicked theEvent: NSEvent, atRow row: Int) {
        switch itemForRow(row)! {
        case .BlogItem(let blog):
            loadBlogViewController(blog)
        case .SectionHeaderItem:
            return
        }
    }
    
    // MARK: Actions
    
    @IBAction func searchFieldSubmit(sender: NSSearchField) {
        let keywords = sender.stringValue
        dataSource.filterByKeywords(keywords)
    }
}
