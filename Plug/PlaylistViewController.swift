//
//  PlaylistViewController.swift
//  Plug
//
//  Created by Alexander Marchant on 7/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PlaylistViewController: NSViewController, NSTableViewDelegate, PlaylistTableViewViewController {
    @IBOutlet weak var tableView: PlaylistTableView!
    var playlist: Playlist?
    var previousMouseOverRow: Int = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if tableView {
            tableView.setDelegate(self)
            tableView.viewController = self
        }
    }
    
    func trackForRow(row: Int) -> Track {
        return playlist!.tracks[row]
    }
    
    func cellViewForRow(row: Int) -> PlaylistTableCellView? {
        if row < 0 {
            return nil
        } else {
            return tableView.viewAtColumn(0, row: row, makeIfNecessary: false) as? PlaylistTableCellView
        }
    }
    
    func tableView(tableView: NSTableView!, rowViewForRow row: Int) -> NSTableRowView! {
        return tableView.makeViewWithIdentifier("PlaylistRowView", owner: self) as IOSStyleTableRowView
    }
    
    func mouseOverTableViewRow(row: Int) {
        if let cellView = cellViewForRow(row) {
            cellView.mouseInside = true
        }
        if let cellView = cellViewForRow(previousMouseOverRow) {
            cellView.mouseInside = false
        }
        previousMouseOverRow = row
    }
    
    func mouseExitedTableView() {
        if let cellView = cellViewForRow(previousMouseOverRow) {
            cellView.mouseInside = false
        }
        previousMouseOverRow = -1
    }
    
    func mouseDidScrollTableView() {
        if let cellView = cellViewForRow(previousMouseOverRow) {
            cellView.mouseInside = false
        }
    }
    
    // TODO: Hook this back up when fixed
//    @IBAction func playPauseButtonClicked(sender: HoverToggleButton) {
//        let row = tableView.rowForView(sender)
//        let cellView = tableView.viewAtColumn(0, row: row, makeIfNecessary: false) as? PlaylistTableCellView
//        cellView!.currentlyPlaying = true
//    }
}