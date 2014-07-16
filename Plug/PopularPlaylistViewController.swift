//
//  PopularPlaylistViewController.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PopularPlaylistViewController: PlaylistViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HypeMachineAPI.Playlists.Popular(PopularPlaylistSubType.Now, success: {playlist in
            self.playlist = playlist
        }, failure: {error in
            println(error)
        })
    }
}
