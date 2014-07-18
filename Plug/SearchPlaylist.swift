//
//  SearchPlaylist.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class SearchPlaylist: Playlist {
    var subType: SearchPlaylistSubType
    var searchKeywords: String
    
    init(tracks: [Track], subType: SearchPlaylistSubType, searchKeywords: String) {
        self.subType = subType
        self.searchKeywords = searchKeywords
        super.init(tracks: tracks, type: PlaylistType.Search)
    }
}

enum SearchPlaylistSubType: String {
    case Newest = "latest"
    case MostFavorites = "loved"
    case MostReblogged = "posted"
}