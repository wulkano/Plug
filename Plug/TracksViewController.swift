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
    @IBOutlet var dataSource: TracksDataSource? {
        didSet {
            dataSourceChanged()
        }
    }
    
    var previousMouseInsideRow: Int = -1
    var anchoredRow: Int?
    var anchoredCellViewViewController: TracksViewController?

    
    let infiniteScrollTriggerHeight: CGFloat = 40
    
    deinit {
        Notifications.unsubscribeAll(observer: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.setDelegate(self)
        tableView.extendedDelegate = self
        
        if dataSource != nil {
            loadDataSource()
        }
    }
    
    func dataSourceChanged() {
        if viewLoaded {
            loadDataSource()
        }
    }
    
    func loadDataSource() {
        addLoaderView()
        tableView.setDataSource(dataSource!)
        dataSource!.loadInitialValues()
    }
    
    func cellViewForRow(row: Int) -> TrackTableCellView? {
        if row < 0 {
            return nil
        } else {
            let cell = tableView.viewAtColumn(0, row: row, makeIfNecessary: false) as? TrackTableCellView
            cell!.dataSource = dataSource
            return cell
        }
    }
    
    override func tableView(tableView: NSTableView, mouseEnteredRow row: Int) {
        if let cellView = cellViewForRow(row) {
            cellView.mouseInside = true
        }
        previousMouseInsideRow = row
    }
    
    override func tableView(tableView: NSTableView, mouseExitedRow row: Int) {
        if let cellView = cellViewForRow(row) {
            cellView.mouseInside = false
        }
    }
    
    override func tableView(tableView: ExtendedTableView, rowDidShow row: Int, direction: RowShowHideDirection) {
        let track = dataSource!.trackForRow(row)
        if track === AudioPlayer.sharedInstance.currentTrack {
            removeStickyTrack()
            Notifications.post(name: Notifications.CurrentTrackDidShow, object: self, userInfo: ["direction": direction.rawValue])
        }
    }
    
    override func tableView(tableView: ExtendedTableView, rowDidHide row: Int, direction: RowShowHideDirection) {
        if let track = dataSource!.trackForRow(row) {
            if track === AudioPlayer.sharedInstance.currentTrack {
                let position = (direction == .Above ? StickyTrackPosition.Top : StickyTrackPosition.Bottom)
                addStickyTrackAtPosition(position)
                Notifications.post(name: Notifications.CurrentTrackDidHide, object: self, userInfo: ["direction": direction.rawValue])
            }
        }
    }
    
    override func addStickyTrackAtPosition(position: StickyTrackPosition) {
        super.addStickyTrackAtPosition(position)
        
        var insets = tableView.defaultExtendedTrackingAreaInsets
        switch position {
        case .Top:
            insets.top += stickyTrackHeight
        case .Bottom:
            insets.bottom += stickyTrackHeight
        }
        
        tableView.extendedTrackingAreaInsets = insets
    }
    
    override func removeStickyTrack() {
        super.removeStickyTrack()
        tableView.extendedTrackingAreaInsets = nil
    }
    
    override func didEndScrollingTableView(tableView: ExtendedTableView) {
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
            AudioPlayer.sharedInstance.playNewTrack(track, dataSource: dataSource!)
        default:
            super.keyDown(theEvent)
        }
    }
    
    override func tableView(tableView: ExtendedTableView, wasRightClicked theEvent: NSEvent, atRow row: Int) {
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