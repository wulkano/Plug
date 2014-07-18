//
//  FeedPlaylistViewController.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class FeedPlaylistViewController: PlaylistViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        HypeMachineAPI.Playlists.Feed(FeedPlaylistSubType.All, {playlist in
            self.playlist = playlist
        }, failure: {error in
            // TODO real error
            println(error)
        })
    }
    
}
