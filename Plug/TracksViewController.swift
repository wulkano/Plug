//
//  TracksViewController.swift
//  Plug
//
//  Created by Alexander Marchant on 7/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class TracksViewController: DataSourceViewController {
    @IBOutlet weak var scrollView: NSScrollView!
    var playlist: Playlist?
    var previousMouseInsideRow: Int = -1
    var anchoredRow: Int?
    var anchoredCellViewViewController: TracksViewController?
    var dataSource: BasePlaylistDataSource? {
        didSet {
            dataSourceChanged()
        }
    }
    
    let infiniteScrollTriggerHeight: CGFloat = 40
    
    deinit {
        Notifications.unsubscribeAll(observer: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.setDelegate(self)
        tableView.extendedDelegate = self
        scrollView.contentInsets = NSEdgeInsetsMake(0, 0, 47, 0) // TODO: Doesn't seem to work yet
        scrollView.scrollerInsets = NSEdgeInsetsMake(0, 0, 47, 0)
    }
    
    func dataSourceChanged() {
        tableView.setDataSource(dataSource!)
        dataSource!.loadInitialValues()
        addLoaderView()
    }
    
    func cellViewForRow(row: Int) -> BasePlaylistTableCellView? {
        if row < 0 {
            return nil
        } else {
            return tableView.viewAtColumn(0, row: row, makeIfNecessary: false) as? BasePlaylistTableCellView
        }
    }
    
    func tableView(tableView: NSTableView, mouseEnteredRow row: Int) {
        if let cellView = cellViewForRow(row) {
            cellView.mouseInside = true
        }
        previousMouseInsideRow = row
    }
    
    func tableView(tableView: NSTableView, mouseExitedRow row: Int) {
        if let cellView = cellViewForRow(row) {
            cellView.mouseInside = false
        }
    }
    
    func tableView(tableView: ExtendedTableView, rowDidShow row: Int) {
        let track = dataSource!.trackForRow(row)
        if track === AudioPlayer.sharedInstance.currentTrack {
            Notifications.post(name: Notifications.CurrentTrackDidShow, object: self, userInfo: nil)
        }
    }
    
    func tableView(tableView: ExtendedTableView, rowDidHide row: Int) {
        if let track = dataSource!.trackForRow(row) {
            if track === AudioPlayer.sharedInstance.currentTrack {
                Notifications.post(name: Notifications.CurrentTrackDidHide, object: self, userInfo: nil)
            }
        }
    }
    
    func didEndScrollingTableView(tableView: ExtendedTableView) {
        if distanceFromBottomOfScrollView() <= infiniteScrollTriggerHeight {
            dataSource!.loadNextPage()
        }
    }
    
    func distanceFromBottomOfScrollView() -> CGFloat {
        var documentViewHeight = (scrollView.documentView as! NSView).frame.height
        var bottomPositionOfDocumentVisibleRect = scrollView.documentVisibleRect.origin.y + scrollView.documentVisibleRect.size.height
        return documentViewHeight - bottomPositionOfDocumentVisibleRect
    }
    
    override func keyDown(theEvent: NSEvent) {
        switch theEvent.keyCode {
        case 36: // Enter
            let row = tableView.selectedRow
            let track = dataSource!.trackForRow(row)!
            AudioPlayer.sharedInstance.play(track)
        default:
            super.keyDown(theEvent)
        }
    }
    
    func tableView(tableView: ExtendedTableView, wasRightClicked theEvent: NSEvent, atRow row: Int) {
        let menuController = TrackContextMenuController(nibName: "TrackContextMenuController", bundle: nil)!
        menuController.loadView()
        menuController.representedObject = dataSource!.trackForRow(row)
        NSMenu.popUpContextMenu(menuController.contextMenu, withEvent: theEvent, forView: view)
    }
    
    override func refresh() {
        addLoaderView()
        dataSource!.refresh()
    }
}