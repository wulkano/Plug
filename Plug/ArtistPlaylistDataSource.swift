//
//  ArtistPlaylistDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 9/2/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class ArtistPlaylistDataSource: BasePlaylistDataSource {
    var artistName: String
    
    init(artistName: String, viewController: BasePlaylistViewController) {
        self.artistName = artistName
        
        super.init(viewController: viewController)
    }
    
    override func requestInitialValues() {
        HypeMachineAPI.Playlists.Artist(artistName,
            success: requestInitialValuesSuccess,
            failure: requestInitialValuesFailure)
    }
    
    override func requestNextPage() {
        HypeMachineAPI.Tracks.Artist(artistName,
            page: currentPage + 1,
            count: 20,
            success: requestNextPageSuccess,
            failure: requestNextPageFailure)
    }
}
