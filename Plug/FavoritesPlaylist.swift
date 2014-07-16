//
//  FavoritesPlaylist.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class FavoritesPlaylist: Playlist {
    init(tracks: [Track]) {
        super.init(tracks: tracks, type: PlaylistType.Favorites)
    }
}
