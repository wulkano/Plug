//
//  DataSourceViewController.swift
//  Plug
//
//  Created by Alex Marchant on 10/22/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class DataSourceViewController: BaseContentViewController, NSTableViewDelegate, ExtendedTableViewDelegate {
    @IBOutlet var tableView: ExtendedTableView!
    
    func requestInitialValuesFinished() {
        removeLoaderView()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        tableView.updateVisibleRows()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        tableView.visibleRows = []
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
