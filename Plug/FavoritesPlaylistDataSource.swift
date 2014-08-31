//
//  FavoritesPlaylistDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 8/12/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class FavoritesPlaylistDataSource: BasePlaylistDataSource {
    override init(tableView: NSTableView) {
        super.init(tableView: tableView)
    }
    
    override func requestInitialValues() {
        HypeMachineAPI.Playlists.Favorites(requestInitialValuesSuccess,
            failure: requestInitialValuesFailure)
    }
    
    override func requestNextPage() {
        HypeMachineAPI.Tracks.Favorites(currentPage + 1, count: 20, success: requestNextPageSuccess, failure: requestNextPageFailure)
    }
}
