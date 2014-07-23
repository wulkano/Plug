//
//  PlaylistViewController.swift
//  Plug
//
//  Created by Alexander Marchant on 7/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PlaylistViewController: NSViewController, NSTableViewDelegate {
    var playlist: Playlist?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        HypeMachineAPI.Playlists.Popular(PopularPlaylistSubType.Now,
            success: {playlist in
                self.playlist = playlist
            }, failure: {error in
                println(error)
            })
    }
    
    func tableView(tableView: NSTableView!, viewForTableColumn tableColumn: NSTableColumn!, row: Int) -> NSView! {
        var cellView = tableView.makeViewWithIdentifier("PlaylistTableCellView", owner: self) as? NSTableCellView
        
        if !cellView {
            let cellViewController = storyboard.instantiateControllerWithIdentifier("Popular Playlist Table Cell View") as NSViewController
            cellView = (cellViewController.view as NSTableCellView)
            cellView!.identifier = "PlaylistTableCellView"
        }
        
        return cellView
    }
}