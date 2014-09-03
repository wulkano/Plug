//
//  BlogPlaylistDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 9/3/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class GenrePlaylistDataSource: BasePlaylistDataSource {
    var genre: Genre
    
    init(genre: Genre, tableView: NSTableView) {
        self.genre = genre
        
        super.init(tableView: tableView)
    }
    
    override func requestInitialValues() {
        HypeMachineAPI.Playlists.GenrePlaylist(genre,
            success: requestInitialValuesSuccess,
            failure: requestInitialValuesFailure)
    }
    
    override func requestNextPage() {
        HypeMachineAPI.Tracks.GenreTracks(genre,
            page: currentPage + 1,
            count: 20,
            success: requestNextPageSuccess,
            failure: requestNextPageFailure)
    }
}
