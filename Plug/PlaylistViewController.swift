//
//  PlaylistViewController.swift
//  Plug
//
//  Created by Alexander Marchant on 7/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PlaylistViewController: NSViewController, NSTableViewDelegate {
    @IBOutlet var tableView: NSTableView
    var playlist: Playlist?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setDelegate(self)
    }
    
    func tableView(tableView: NSTableView!, viewForTableColumn tableColumn: NSTableColumn!, row: Int) -> NSView! {
        var cellView = tableView.makeViewWithIdentifier("PlaylistTableCellView", owner: self) as? NSTableCellView
        
        if !cellView {
            let cellViewController = PlaylistTableCellViewController(playlistType: playlist!.type)
            cellViewController.loadView()
            cellView = (cellViewController.view as NSTableCellView)
            cellView!.identifier = "PlaylistTableCellView"
        }
        
        return cellView
    }
}