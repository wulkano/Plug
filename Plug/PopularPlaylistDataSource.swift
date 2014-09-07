//
//  PopularPlaylistDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 8/12/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PopularPlaylistDataSource: BasePlaylistDataSource {
    var playlistSubType: PopularPlaylistSubType
    
    init(playlistSubType: PopularPlaylistSubType, viewController: BasePlaylistViewController) {
        self.playlistSubType = playlistSubType
        
        super.init(viewController: viewController)
    }
    
    override func requestInitialValues() {
        HypeMachineAPI.Playlists.Popular(playlistSubType,
            success: requestInitialValuesSuccess,
            failure: requestInitialValuesFailure)
    }
    
    override func requestNextPage() {
        HypeMachineAPI.Tracks.Popular(playlistSubType,
            page: currentPage + 1,
            count: 20,
            success: requestNextPageSuccess,
            failure: requestNextPageFailure)
    }
}
