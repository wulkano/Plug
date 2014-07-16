//
//  PopularPlaylist.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PopularPlaylist: Playlist {
    var subType: PopularPlaylistSubType
    
    init(tracks: [Track], subType: PopularPlaylistSubType) {
        self.subType = subType
        super.init(tracks: tracks, type: PlaylistType.Popular)
    }
}

enum PopularPlaylistSubType: String {
    case Now = "now"
    case LastWeek = "lastweek"
    case NoRemix = "noremix"
    case Remix = "remix"
}