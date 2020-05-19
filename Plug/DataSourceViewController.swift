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
        
        tableView = ExtendedTableView()
        tableView.headerView = nil
        tableView.intercellSpacing = NSSize(width: 0, height: 0)
		let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "Col0"))
        tableView.addTableColumn(column)
        
        scrollView.documentView = tableView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.horizontalScrollElasticity = .none
        
        tableView.contentInsets = tableViewInsets
        tableView.scrollerInsets = tableViewInsets
    }
    
    func nextPageDidLoad(_ pageNumber: Int) {
        if pageNumber == 0 {
            removeLoaderView()
            scrollView.finishedRefresh()
        }
    }
    
    func sectionHeaderCellView(_ tableView: NSTableView) -> SectionHeaderTableCellView {
        let id = "SectionHeaderCellViewID"
		var cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: id), owner: self) as? SectionHeaderTableCellView
        
        if cellView == nil {
            cellView = SectionHeaderTableCellView()
			cellView!.identifier = NSUserInterfaceItemIdentifier(rawValue: id)
            
            cellView!.titleTextField = NSTextField()
            cellView!.titleTextField.isEditable = false
            cellView!.titleTextField.isSelectable = false
            cellView!.titleTextField.isBordered = false
            cellView!.titleTextField.drawsBackground = false
            cellView!.titleTextField.font = appFont(size: 14, weight: .medium)
            cellView!.titleTextField.textColor = NSColor(red256: 138, green256: 146, blue256: 150)
            cellView!.addSubview(cellView!.titleTextField)
            cellView!.titleTextField.snp.makeConstraints { make in
                make.centerY.equalTo(cellView!).offset(-1)
                make.left.equalTo(cellView!).offset(9)
                make.right.equalTo(cellView!).offset(-9)
            }
        }
        
        return cellView!
    }
    
    func groupRowView(_ tableView: NSTableView) -> GroupRowView {
        let id = "GroupRowID"
		var rowView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: id), owner: self) as? GroupRowView
        
        if rowView == nil {
            rowView = GroupRowView()
			rowView!.identifier = NSUserInterfaceItemIdentifier(rawValue: id)
        }
        
        return rowView!
    }
    
    func dataSourceChanged() {}
    
    // MARK: NSViewController
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
//        tableView.updateVisibleRows()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
//        tableView.previousVisibleRows = []
    }
    
    // MARK: BaseContentViewController
    
    override func refresh() {
        addLoaderView()
        dataSource!.refresh()
    }
    
    override func addStickyTrackAtPosition(_ position: StickyTrackPosition) {
        super.addStickyTrackAtPosition(position)
        
        var stickyTrackInsets = tableViewInsets
        
        switch position {
        case .top:
            stickyTrackInsets.top += stickyTrackController.trackViewHeight
        case .bottom:
            stickyTrackInsets.bottom += stickyTrackController.trackViewHeight
        }
        
        if stickyTrackBelongsToUs {
            tableView.contentInsets = tableViewInsets
            tableView.scrollerInsets = stickyTrackInsets
        } else {
            tableView.contentInsets = stickyTrackInsets
            tableView.scrollerInsets = stickyTrackInsets
        }
    }
    
    override func removeStickyTrack() {
        super.removeStickyTrack()
        tableView.contentInsets = tableViewInsets
        tableView.scrollerInsets = tableViewInsets
    }
    
    // MARK: RefreshScrollViewDelegate
    
    func didPullToRefresh() {
        dataSource!.refresh()
    }
    
    // MARK: ExtendedTableViewDelegate default implementations
    
    func tableView(_ tableView: ExtendedTableView, wasClicked theEvent: NSEvent, atRow row: Int) {}
    func tableView(_ tableView: ExtendedTableView, wasRightClicked theEvent: NSEvent, atRow row: Int) {}
    func tableView(_ tableView: ExtendedTableView, wasDoubleClicked theEvent: NSEvent, atRow row: Int) {}
    func tableView(_ tableView: ExtendedTableView, mouseEnteredRow row: Int) {}
    func tableView(_ tableView: ExtendedTableView, mouseExitedRow row: Int) {}
    func tableView(_ tableView: ExtendedTableView, rowDidShow row: Int, direction: RowShowHideDirection) {}
    func tableView(_ tableView: ExtendedTableView, rowDidHide row: Int, direction: RowShowHideDirection) {}
    func tableView(_ tableView: ExtendedTableView, rowDidStartToShow row: Int, direction: RowShowHideDirection) {}
    func tableView(_ tableView: ExtendedTableView, rowDidStartToHide row: Int, direction: RowShowHideDirection) {}
    func didEndScrollingTableView(_ tableView: ExtendedTableView) {}
    func didScrollTableView(_ tableView: ExtendedTableView) {}
}
