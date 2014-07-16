//
//  Playlist.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class Playlist: NSObject {
    var tracks: [Track]
    var type: PlaylistType
    
    init(tracks: [Track], type: PlaylistType) {
        self.tracks = tracks
        self.type = type
        super.init()
    }
}

enum PlaylistType {
    case Popular
    case Favorites
    case Latest
    case Feed
    case Search
}
