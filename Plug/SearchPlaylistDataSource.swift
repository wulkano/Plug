//
//  SearchPlaylistDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 8/18/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class SearchPlaylistDataSource: BasePlaylistDataSource {
    var searchKeywords: String
    var playlistSubType: SearchPlaylistSubType
    
    init(searchKeywords: String, playlistSubType: SearchPlaylistSubType, viewController: BasePlaylistViewController) {
        self.searchKeywords = searchKeywords
        self.playlistSubType = playlistSubType
        
        super.init(viewController: viewController)
    }
    
    override func requestInitialValues() {
        HypeMachineAPI.Playlists.Search(searchKeywords,
            subType: playlistSubType,
            success: requestInitialValuesSuccess,
            failure: requestInitialValuesFailure)
    }
    
    override func requestNextPage() {
        HypeMachineAPI.Tracks.Search(searchKeywords,
            subType: playlistSubType,
            page: currentPage + 1,
            count: 20,
            success: requestNextPageSuccess,
            failure: requestNextPageFailure)
    }
}
