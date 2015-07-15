//
//  DataSourceViewController.swift
//  Plug
//
//  Created by Alex Marchant on 10/22/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class DataSourceViewController: BaseContentViewController, NSTableViewDelegate, ExtendedTableViewDelegate, RefreshScrollViewDelegate {
    var dataSource: HypeMachineDataSource? {
        didSet { dataSourceChanged() }
    }
    var scrollView: RefreshScrollView!
    var tableView: ExtendedTableView!
    
    func loadScrollViewAndTableView() {
        scrollView = RefreshScrollView(delegate: self)
        view.addSubview(scrollView)
        
        tableView = InsetTableView()
        tableView.headerView = nil
        tableView.intercellSpacing = NSSize(width: 0, height: 0)
        let column = NSTableColumn(identifier: "Col0")
        tableView.addTableColumn(column)
        
        scrollView.documentView = tableView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.horizontalScrollElasticity = .None
    }
    
    func nextPageDidLoad(pageNumber: Int) {
        if pageNumber == 0 {
            removeLoaderView()
            scrollView.finishedRefresh()
        }
    }
    
    func sectionHeaderCellView(tableView: NSTableView) -> SectionHeaderTableCellView {
        let id = "SectionHeaderCellViewID"
        var cellView = tableView.makeViewWithIdentifier(id, owner: self) as? SectionHeaderTableCellView
        
        if cellView == nil {
            cellView = SectionHeaderTableCellView()
            cellView!.identifier = id
            
            cellView!.titleTextField = NSTextField()
            cellView!.titleTextField.editable = false
            cellView!.titleTextField.selectable = false
            cellView!.titleTextField.bordered = false
            cellView!.titleTextField.drawsBackground = false
            cellView!.titleTextField.font = NSFont(name: "HelveticaNeue-Medium", size: 14)
            cellView!.titleTextField.textColor = NSColor(red256: 138, green256: 146, blue256: 150)
            cellView!.addSubview(cellView!.titleTextField)
            cellView!.titleTextField.snp_makeConstraints { make in
                make.centerY.equalTo(cellView!).offset(-1)
                make.left.equalTo(cellView!).offset(9)
                make.right.equalTo(cellView!).offset(-9)
            }
        }
        
        return cellView!
    }
    
    func groupRowView(tableView: NSTableView) -> GroupRowView {
        let id = "GroupRowID"
        var rowView = tableView.makeViewWithIdentifier(id, owner: self) as? GroupRowView
        
        if rowView == nil {
            rowView = GroupRowView()
            rowView!.identifier = id
        }
        
        return rowView!
    }
    
    func dataSourceChanged() {}
    
    // MARK: NSViewController
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        tableView.updateVisibleRows()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        tableView.visibleRows = []
    }
    
    // MARK: BaseContentViewController
    
    override func refresh() {
        addLoaderView()
        dataSource!.refresh()
    }
    
    // MARK: RefreshScrollViewDelegate
    
    func didPullToRefresh() {
        dataSource!.refresh()
    }
    
    // MARK: ExtendedTableViewDelegate default implementations
    
    func tableView(tableView: ExtendedTableView, wasClicked theEvent: NSEvent, atRow row: Int) {}
    func tableView(tableView: ExtendedTableView, wasRightClicked theEvent: NSEvent, atRow row: Int) {}
    func tableView(tableView: ExtendedTableView, mouseEnteredRow row: Int) {}
    func tableView(tableView: ExtendedTableView, mouseExitedRow row: Int) {}
    func tableView(tableView: ExtendedTableView, rowDidShow row: Int, direction: RowShowHideDirection) {}
    func tableView(tableView: ExtendedTableView, rowDidHide row: Int, direction: RowShowHideDirection) {}
    func didEndScrollingTableView(tableView: ExtendedTableView) {}
    func didScrollTableView(tableView: ExtendedTableView) {}
}
