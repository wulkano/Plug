//
//  FeedPlaylistDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 8/12/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class FeedPlaylistDataSource: BasePlaylistDataSource {
    var playlistSubType: FeedPlaylistSubType
    
    init(playlistSubType: FeedPlaylistSubType, tableView: NSTableView) {
        self.playlistSubType = playlistSubType
        
        super.init(tableView: tableView)
    }
    
    override func requestInitialValues() {
        HypeMachineAPI.Playlists.Feed(playlistSubType,
            success: requestInitialValuesSuccess,
            failure: requestInitialValuesFailure)
    }
    
    override func requestNextPage() {
        HypeMachineAPI.Tracks.Feed(playlistSubType,
            page: currentPage + 1,
            count: 20,
            success: requestNextPageSuccess,
            failure: requestNextPageFailure)
    }
}