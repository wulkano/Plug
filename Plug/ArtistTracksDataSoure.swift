//
//  ArtistTracksDataSoure.swift
//  Plug
//
//  Created by Alex Marchant on 6/3/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import HypeMachineAPI

class ArtistTracksDataSource: TracksDataSource {
    var artistName: String
    
    init(artistName: String) {
        self.artistName = artistName
        super.init()
    }
    
    override func requestInitialValues() {
        HypeMachineAPI.Requests.Artists.showTracks(name: artistName, optionalParams: nil, callback: requestInitialValuesResponse)
    }
    
    override func requestNextPage() {
        HypeMachineAPI.Requests.Artists.showTracks(name: artistName, optionalParams: nextPageParams, callback: requestNextPageResponse)
    }
}