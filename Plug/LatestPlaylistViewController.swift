//
//  LatestPlaylistViewController.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class LatestPlaylistViewController: PlaylistViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        HypeMachineAPI.Playlists.Latest({playlist in
            self.playlist = playlist
        }, failure: {error in
            // TODO real error            
            println(error)
        })
    }
}