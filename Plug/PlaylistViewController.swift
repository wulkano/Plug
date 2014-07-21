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
}