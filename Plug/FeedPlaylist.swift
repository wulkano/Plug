//
//  FeedPlaylist.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class FeedPlaylist: Playlist {
    var subType: FeedPlaylistSubType
    
    init(tracks: [Track], subType: FeedPlaylistSubType) {
        self.subType = subType
        super.init(tracks: tracks, type: PlaylistType.Feed)
    }
}

enum FeedPlaylistSubType: String {
    case All = "all"
    case Friends = "friends"
    case Artists = "artists"
    case Blogs = "blogs"
}