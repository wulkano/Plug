//
//  PlaylistViewController.swift
//  Plug
//
//  Created by Alexander Marchant on 7/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PlaylistViewController: NSViewController, NSTableViewDelegate {
    let selectedRowColor = NSColor(red256: 0, green256: 0, blue256: 0)
    
    @IBOutlet var tableView: NSTableView
    var playlist: Playlist?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.setDelegate(self)
    }
    
    func tableView(tableView: NSTableView!, rowViewForRow row: Int) -> NSTableRowView! {
//        TODO This is getting rebuilt (below makeViewWith... not working)
        let rowIdentifier = "RowView"
        var rowView: PlaylistTableRowView? = tableView.makeViewWithIdentifier(rowIdentifier, owner: self) as? PlaylistTableRowView
        if !rowView {
            // Size doesn't matter, the table will set it
            rowView = PlaylistTableRowView(frame: NSZeroRect)
            
            // This seemingly magical line enables your view to be found
            // next time "makeViewWithIdentifier" is called.
            rowView!.identifier = rowIdentifier;
        }
        
        // Can customize properties here. Note that customizing
        // 'backgroundColor' isn't going to work at this point since the table
        // will reset it later. Use 'didAddRow' to customize if desired.
        
        return rowView;
    }
}