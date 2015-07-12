//
//  FriendsViewController.swift
//  Plug
//
//  Created by Alex Marchant on 8/1/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI

class UsersViewController: DataSourceViewController {
    var dataSource: FriendsDataSource!
    override var analyticsViewName: String {
        return "MainWindow/Friends"
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

        dataSource = FriendsDataSource(viewController: self)
        tableView.setDataSource(dataSource)
        dataSource.loadInitialValues()
    }
    
    func loadSingleFriendView(friend: HypeMachineAPI.User) {
        let viewController = UserViewController(user: friend)
        Notifications.post(name: Notifications.PushViewController, object: self, userInfo: ["viewController": viewController])
    }
    
    override func refresh() {
        addLoaderView()
        dataSource.refresh()
    }
    
    // MARK: NSTableViewDelegate
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let id = "UserTableCellViewID"
        var cellView = tableView.makeViewWithIdentifier(id, owner: self) as? UserTableCellView
        
        if cellView == nil {
            cellView = UserTableCellView()
            cellView!.identifier = id
            
            cellView!.avatarView = CircleMaskImageView()
            cellView!.avatarView.image = NSImage(named: "Avatar-Placeholder")!
            cellView!.addSubview(cellView!.avatarView)
            cellView!.avatarView.snp_makeConstraints { make in
                make.centerY.equalTo(cellView!)
                make.width.equalTo(36)
                make.height.equalTo(36)
                make.left.equalTo(cellView!).offset(17)
            }
            
            cellView!.fullNameTextField = NSTextField()
            cellView!.fullNameTextField.editable = false
            cellView!.fullNameTextField.selectable = false
            cellView!.fullNameTextField.bordered = false
            cellView!.fullNameTextField.drawsBackground = false
            cellView!.fullNameTextField.font = NSFont(name: "HelveticaNeue-Medium", size: 14)
            cellView!.addSubview(cellView!.fullNameTextField)
            cellView!.fullNameTextField.snp_makeConstraints { make in
                make.left.equalTo(cellView!.avatarView.snp_right).offset(22)
                make.top.equalTo(cellView!).offset(9)
                make.right.equalTo(cellView!).offset(27)
            }
            
            cellView!.usernameTextField = NSTextField()
            cellView!.usernameTextField.editable = false
            cellView!.usernameTextField.selectable = false
            cellView!.usernameTextField.bordered = false
            cellView!.usernameTextField.drawsBackground = false
            cellView!.usernameTextField.font = NSFont(name: "HelveticaNeue-Medium", size: 13)
            cellView!.usernameTextField.textColor = NSColor(red256: 138, green256: 146, blue256: 150)
            cellView!.addSubview(cellView!.usernameTextField)
            cellView!.usernameTextField.snp_makeConstraints { make in
                make.left.equalTo(cellView!.avatarView.snp_right).offset(22)
                make.top.equalTo(cellView!.fullNameTextField.snp_bottom).offset(1)
                make.right.equalTo(cellView!).offset(27)
            }
            
            let arrow = NSImageView()
            arrow.image = NSImage(named: "List-Arrow")!
            cellView!.addSubview(arrow)
            arrow.snp_makeConstraints { make in
                make.centerY.equalTo(cellView!)
                make.right.equalTo(cellView!).offset(-15)
            }
        }
        
        return cellView
    }
    
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let id = "IOSStyleTableRowViewID"
        var rowView = tableView.makeViewWithIdentifier(id, owner: self) as? IOSStyleTableRowView
        
        if rowView == nil {
            rowView = IOSStyleTableRowView()
            rowView!.identifier = id
            rowView!.separatorSpacing = 73
        }
        
        return rowView
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 64
    }
    
    // MARK: ExtendedTableViewDelegate
    
    
    override func tableView(tableView: NSTableView, wasClicked theEvent: NSEvent, atRow row: Int) {
        if let item: AnyObject = dataSource.itemForRow(row) {
            loadSingleFriendView(item as! HypeMachineAPI.User)
        }
    }
    
    // MARK: Actions
    
    
    func searchFieldSubmit(sender: NSSearchField) {
        let keywords = sender.stringValue
        dataSource.filterByKeywords(keywords)
    }
}