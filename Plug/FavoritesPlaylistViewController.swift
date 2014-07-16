//
//  FavoritesPlaylistViewController.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class FavoritesPlaylistViewController: PlaylistViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HypeMachineAPI.Playlists.Favorites({playlist in
            self.playlist = playlist
        }, failure: {error in
            println(error)
        })
    }
}
