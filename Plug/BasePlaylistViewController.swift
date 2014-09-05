//
//  PlaylistViewController.swift
//  Plug
//
//  Created by Alexander Marchant on 7/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class BasePlaylistViewController: NSViewController, NSTableViewDelegate, ExtendedTableViewDelegate {
    @IBOutlet weak var tableView: ExtendedTableView!
    @IBOutlet weak var scrollView: NSScrollView!
    var playlist: Playlist?
    var previousMouseInsideRow: Int = -1
    var dataSource: BasePlaylistDataSource? {
        didSet {
            dataSourceChanged()
        }
    }
    
    let infiniteScrollTriggerHeight: CGFloat = 40
    
    deinit {
        Notifications.Unsubscribe.All(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "scrollViewDidScroll:", name: NSScrollViewDidEndLiveScrollNotification, object: scrollView)
        
        tableView.setDelegate(self)
        tableView.extendedDelegate = self
        scrollView.contentInsets = NSEdgeInsetsMake(0, 0, 47, 0) // TODO: Doesn't seem to work yet
        scrollView.scrollerInsets = NSEdgeInsetsMake(0, 0, 47, 0)
        
        if dataSource != nil {
            dataSource!.tableView = tableView
            tableView.setDataSource(dataSource!)
        }
    }
    
    func scrollViewDidScroll(notification: NSNotification) {
        if distanceFromBottomOfScrollView() <= infiniteScrollTriggerHeight {
            dataSource!.loadNextPage()
        }
    }
    
    func distanceFromBottomOfScrollView() -> CGFloat {
        var documentViewHeight = scrollView.documentView.frame.height
        var bottomPositionOfDocumentVisibleRect = scrollView.documentVisibleRect.origin.y + scrollView.documentVisibleRect.size.height
        return documentViewHeight - bottomPositionOfDocumentVisibleRect
    }
    
    func dataSourceChanged() {
        tableView.setDataSource(self.dataSource!)
        self.dataSource!.tableView = tableView
        self.dataSource!.loadInitialValues()
    }
    
    func cellViewForRow(row: Int) -> BasePlaylistTableCellView? {
        if row < 0 {
            return nil
        } else {
            return tableView.viewAtColumn(0, row: row, makeIfNecessary: false) as? BasePlaylistTableCellView
        }
    }
    
    func tableView(tableView: NSTableView, mouseEnteredRow row: Int) {
        cellViewForRow(row)!.mouseInside = true
        previousMouseInsideRow = row
    }
    
    func tableView(tableView: NSTableView, mouseExitedRow row: Int) {
        cellViewForRow(row)!.mouseInside = false
    }
    
    func mouseDidScrollTableView() {
        if let cellView = cellViewForRow(previousMouseInsideRow) {
            cellView.mouseInside = false
        }
    }
    
    override func keyDown(theEvent: NSEvent!) {
        switch theEvent.keyCode {
        case 36: // Enter
            let row = tableView.selectedRow
            let track = dataSource!.trackForRow(row)
            AudioPlayer.sharedInstance.play(track)
        default:
            super.keyDown(theEvent)
        }
    }
}